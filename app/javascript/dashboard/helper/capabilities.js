import CapabilitiesAPI from 'dashboard/api/captain/capabilities';
import { webMcpRegistry } from 'dashboard/helper/webmcp/registry';
import {
  buildImperativeToolsForRoute,
  getImperativeHandler,
  normalizeRoutePath,
} from 'dashboard/helper/webmcp/imperativeTools';

const capabilityCache = new Map();
let accountCapabilities = [];
let cachedAccountId = null;

const parseCapabilitiesResponse = data => {
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.payload)) return data.payload;
  if (Array.isArray(data?.capabilities)) return data.capabilities;
  return [];
};

const FALLBACK_CAPABILITIES = [
  {
    id: 'create_label',
    title: 'Create Label',
    description: 'Create a new conversation label',
    webmcp_mode: 'declarative',
    exposure: ['copilot', 'webmcp'],
  },
  {
    id: 'create_canned_response',
    title: 'Create Canned Response',
    description: 'Create a canned response with short code and content',
    webmcp_mode: 'declarative',
    exposure: ['copilot', 'webmcp'],
  },
  {
    id: 'create_custom_attribute',
    title: 'Create Custom Attribute',
    description: 'Create a custom attribute for contacts or conversations',
    webmcp_mode: 'declarative',
    exposure: ['copilot', 'webmcp'],
  },
];

export { normalizeRoutePath };

const getToolIdsForRouteFallback = normalizedRoute => {
  if (normalizedRoute.includes('/settings/labels')) {
    return ['create_label'];
  }
  if (normalizedRoute.includes('/settings/canned')) {
    return ['create_canned_response'];
  }
  if (normalizedRoute.includes('/settings/attributes')) {
    return ['create_custom_attribute'];
  }
  return [];
};

export const clearCapabilitiesCache = () => {
  capabilityCache.clear();
  accountCapabilities = [];
  cachedAccountId = null;
};

export const fetchCapabilities = async accountId => {
  if (cachedAccountId === accountId && accountCapabilities.length) {
    return accountCapabilities;
  }

  try {
    const { data } = await CapabilitiesAPI.get({});
    accountCapabilities = parseCapabilitiesResponse(data);
  } catch {
    accountCapabilities = FALLBACK_CAPABILITIES;
  }

  cachedAccountId = accountId;
  return accountCapabilities;
};

export const fetchCapabilitiesForRoute = async ({
  route,
  accountId,
  force = false,
} = {}) => {
  const normalizedRoute = normalizeRoutePath(route, accountId);
  const cacheKey = `${accountId}:${normalizedRoute}`;

  if (!force && capabilityCache.has(cacheKey)) {
    return capabilityCache.get(cacheKey);
  }

  try {
    const { data } = await CapabilitiesAPI.get({ route: normalizedRoute });
    const capabilities = parseCapabilitiesResponse(data);
    capabilityCache.set(cacheKey, capabilities);
    return capabilities;
  } catch {
    const fallback = FALLBACK_CAPABILITIES.filter(capability =>
      getToolIdsForRouteFallback(normalizedRoute).includes(capability.id)
    );
    capabilityCache.set(cacheKey, fallback);
    return fallback;
  }
};

export const getCapabilityById = capabilityId => {
  const capability = accountCapabilities.find(item => item.id === capabilityId);
  if (capability) return capability;

  return FALLBACK_CAPABILITIES.find(item => item.id === capabilityId) || null;
};

export const registerRouteCapabilities = async ({
  route,
  accountId,
  capabilities = [],
}) => {
  if (!webMcpRegistry.isSupported()) {
    return async () => {};
  }

  const normalizedRoute = normalizeRoutePath(route, accountId);
  const tools = buildImperativeToolsForRoute(normalizedRoute, capabilities);
  const registeredNames = [];

  await Promise.all(
    tools.map(async tool => {
      const toolName = await webMcpRegistry.registerTool(tool);
      if (toolName) registeredNames.push(toolName);
    })
  );

  return async () => {
    await Promise.all(
      registeredNames.map(name => webMcpRegistry.unregisterTool(name))
    );
  };
};

export const executeCapability = async (name, args = {}) => {
  try {
    return await webMcpRegistry.executeTool(name, args);
  } catch (registryError) {
    const handler = getImperativeHandler(name);
    if (handler) {
      return handler(args);
    }

    throw registryError;
  }
};

export const buildInputSchemaFromParams = (params = {}) => {
  const properties = {};
  const required = [];

  Object.entries(params).forEach(([name, config]) => {
    properties[name] = {
      type: config.type || 'string',
      description: config.description || config.title || name,
    };

    if (config.enum) {
      properties[name].enum = config.enum;
    }

    if (config.required) {
      required.push(name);
    }
  });

  return {
    type: 'object',
    properties,
    ...(required.length ? { required } : {}),
  };
};

export const getParamDescription = (capability, paramName) => {
  const param = capability?.params?.[paramName];
  if (!param) return paramName;

  return param.description || param.title || paramName;
};

export const filterCapabilities = (
  capabilities,
  { route, exposure = 'webmcp', webmcpMode } = {}
) => {
  const normalizedRoute = normalizeRoutePath(route);

  return capabilities.filter(capability => {
    if (exposure && !capability.exposure?.includes(exposure)) return false;
    if (webmcpMode && capability.webmcp_mode !== webmcpMode) return false;
    if (
      normalizedRoute &&
      capability.route &&
      !normalizeRoutePath(capability.route).includes(
        normalizedRoute.replace(/\/app\/accounts\/:[^/]+/, '')
      )
    ) {
      return false;
    }
    return true;
  });
};
