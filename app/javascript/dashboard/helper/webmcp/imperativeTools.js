/* global axios */
import store from 'dashboard/store';
import LabelsAPI from 'dashboard/api/labels';
import CampaignsAPI from 'dashboard/api/campaigns';
import AutomationsAPI from 'dashboard/api/automation';
import MacrosAPI from 'dashboard/api/macros';
import ConversationApi from 'dashboard/api/inbox/conversation';
import ConversationLabelsAPI from 'dashboard/api/conversations';
import IntegrationsAPI from 'dashboard/api/integrations';
import WebhooksAPI from 'dashboard/api/webhooks';
import DashboardAppsAPI from 'dashboard/api/dashboardApps';
import EnterpriseAccountAPI from 'dashboard/api/enterprise/account';

const parseJson = (value, fieldName) => {
  try {
    return JSON.parse(value);
  } catch {
    throw new Error(`Invalid JSON in ${fieldName}`);
  }
};

const IMPERATIVE_TOOL_DEFINITIONS = {
  search_conversations: {
    name: 'search_conversations',
    description: 'Search conversations by query and filters',
    inputSchema: {
      type: 'object',
      properties: {
        query: { type: 'string', description: 'Search query' },
        status: { type: 'string', description: 'Conversation status filter' },
        inbox_id: { type: 'number', description: 'Inbox ID filter' },
      },
    },
    execute: async args => {
      const { data } = await ConversationApi.search({ q: args.query || '' });
      return { conversations: data.payload || data };
    },
  },
  get_conversation: {
    name: 'get_conversation',
    description: 'Get details for a conversation',
    inputSchema: {
      type: 'object',
      properties: {
        conversation_id: { type: 'number', description: 'Conversation ID' },
      },
      required: ['conversation_id'],
    },
    execute: async args => {
      const { data } = await ConversationApi.show(args.conversation_id);
      return { conversation: data };
    },
  },
  list_labels: {
    name: 'list_labels',
    description: 'List all conversation labels in the account',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await LabelsAPI.get();
      return { labels: data.payload || data };
    },
  },
  create_label: {
    name: 'create_label',
    description: 'Create a new conversation label',
    inputSchema: {
      type: 'object',
      properties: {
        title: { type: 'string', description: 'Label name' },
        color: { type: 'string', description: 'Hex color code' },
        description: { type: 'string', description: 'Label description' },
        show_on_sidebar: {
          type: 'boolean',
          description: 'Whether the label appears in the sidebar',
        },
      },
      required: ['title'],
    },
    execute: async args => {
      const label = await store.dispatch('labels/create', {
        title: String(args.title).toLowerCase(),
        color: args.color || '#000000',
        description: args.description || '',
        show_on_sidebar: args.show_on_sidebar ?? true,
      });
      return { label };
    },
  },
  list_campaigns: {
    name: 'list_campaigns',
    description: 'List campaigns configured for the account',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await CampaignsAPI.get();
      return { campaigns: data.payload || data };
    },
  },
  create_campaign: {
    name: 'create_campaign',
    description: 'Create a live chat campaign',
    inputSchema: {
      type: 'object',
      properties: {
        title: { type: 'string', description: 'Campaign title' },
        message: { type: 'string', description: 'Campaign message content' },
        inbox_id: { type: 'number', description: 'Inbox ID' },
        sender_id: { type: 'number', description: 'Agent sender ID' },
        enabled: {
          type: 'boolean',
          description: 'Whether the campaign is enabled',
        },
        trigger_only_during_business_hours: {
          type: 'boolean',
          description: 'Limit campaign to business hours',
        },
        trigger_rules: {
          type: 'object',
          description: 'Campaign trigger rules payload',
        },
      },
      required: ['title', 'message', 'inbox_id'],
    },
    execute: async args => {
      const campaign = await store.dispatch('campaigns/create', {
        title: args.title,
        message: args.message,
        inbox_id: args.inbox_id,
        sender_id: args.sender_id,
        enabled: args.enabled ?? true,
        trigger_only_during_business_hours:
          args.trigger_only_during_business_hours ?? false,
        trigger_rules: args.trigger_rules || {},
        campaign_type: 'ongoing',
      });
      return { campaign };
    },
  },
  list_automation_rules: {
    name: 'list_automation_rules',
    description: 'List automation rules for the account',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await AutomationsAPI.get();
      return { automation_rules: data.payload || data };
    },
  },
  create_automation_rule: {
    name: 'create_automation_rule',
    description: 'Create an automation rule',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Automation rule name' },
        description: {
          type: 'string',
          description: 'Automation rule description',
        },
        event_name: { type: 'string', description: 'Trigger event name' },
        conditions: {
          type: 'array',
          description: 'Rule conditions',
        },
        actions: {
          type: 'array',
          description: 'Rule actions',
        },
        active: { type: 'boolean', description: 'Whether the rule is active' },
      },
      required: ['name', 'event_name', 'conditions', 'actions'],
    },
    execute: async args => {
      const { data } = await AutomationsAPI.create({
        name: args.name,
        description: args.description || '',
        event_name: args.event_name,
        conditions: args.conditions,
        actions: args.actions,
        active: args.active ?? true,
      });
      return { automation_rule: data };
    },
  },
  list_macros: {
    name: 'list_macros',
    description: 'List macros available in the account',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await MacrosAPI.get();
      return { macros: data.payload || data };
    },
  },
  create_macro: {
    name: 'create_macro',
    description: 'Create a macro with actions',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Macro name' },
        actions: { type: 'array', description: 'Macro actions' },
        visibility: {
          type: 'string',
          description: 'Macro visibility (global or personal)',
        },
      },
      required: ['name', 'actions'],
    },
    execute: async args => {
      const { data } = await MacrosAPI.create({
        name: args.name,
        actions: args.actions,
        visibility: args.visibility || 'global',
      });
      return { macro: data };
    },
  },
  execute_macro: {
    name: 'execute_macro',
    description: 'Execute a macro on one or more conversations',
    inputSchema: {
      type: 'object',
      properties: {
        macro_id: { type: 'number', description: 'Macro ID' },
        conversation_ids: {
          type: 'array',
          items: { type: 'number' },
          description: 'Conversation IDs to apply the macro to',
        },
      },
      required: ['macro_id', 'conversation_ids'],
    },
    execute: async args => {
      const { data } = await MacrosAPI.executeMacro({
        macroId: args.macro_id,
        conversationIds: args.conversation_ids,
      });
      return { result: data };
    },
  },
  assign_conversation: {
    name: 'assign_conversation',
    description: 'Assign the open conversation to an agent or team',
    inputSchema: {
      type: 'object',
      properties: {
        conversation_id: { type: 'number', description: 'Conversation ID' },
        assignee_id: { type: 'number', description: 'Agent assignee ID' },
        assignee_type: {
          type: 'string',
          description: 'Assignee type (User or Team)',
        },
        team_id: {
          type: 'number',
          description: 'Team ID when assigning a team',
        },
      },
      required: ['conversation_id'],
    },
    execute: async args => {
      if (args.team_id) {
        const { data } = await ConversationApi.assignTeam({
          conversationId: args.conversation_id,
          teamId: args.team_id,
        });
        return { conversation: data };
      }

      const { data } = await ConversationApi.assignAgent({
        conversationId: args.conversation_id,
        agentId: args.assignee_id,
        assigneeType: args.assignee_type || 'User',
      });
      return { conversation: data };
    },
  },
  resolve_conversation: {
    name: 'resolve_conversation',
    description: 'Resolve or reopen a conversation',
    inputSchema: {
      type: 'object',
      properties: {
        conversation_id: { type: 'number', description: 'Conversation ID' },
        status: {
          type: 'string',
          description: 'Conversation status (resolved or open)',
        },
      },
      required: ['conversation_id', 'status'],
    },
    execute: async args => {
      const { data } = await ConversationApi.toggleStatus({
        conversationId: args.conversation_id,
        status: args.status || 'resolved',
      });
      return { conversation: data };
    },
  },
  add_label_to_conversation: {
    name: 'add_label_to_conversation',
    description: 'Add a label to a conversation',
    inputSchema: {
      type: 'object',
      properties: {
        conversation_id: { type: 'number', description: 'Conversation ID' },
        label_name: { type: 'string', description: 'Label title to add' },
      },
      required: ['conversation_id', 'label_name'],
    },
    execute: async args => {
      const { data } = await ConversationLabelsAPI.getLabels(
        args.conversation_id
      );
      const currentLabels = data.payload || [];
      const labels = [...new Set([...currentLabels, args.label_name])];

      await store.dispatch('conversationLabels/update', {
        conversationId: args.conversation_id,
        labels,
      });

      return { conversation_id: args.conversation_id, labels };
    },
  },
  list_integrations: {
    name: 'list_integrations',
    description: 'List available integrations and their connection status',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await IntegrationsAPI.get();
      return { integrations: data.payload || data };
    },
  },
  get_integration: {
    name: 'get_integration',
    description: 'Get details for a specific integration',
    inputSchema: {
      type: 'object',
      properties: {
        integration_id: {
          type: 'string',
          description: 'Integration ID (e.g. slack, openai, webhook)',
        },
      },
      required: ['integration_id'],
    },
    execute: async args => {
      const { data } = await IntegrationsAPI.get();
      const integrations = data.payload || data;
      const integration = integrations.find(
        record => record.id === args.integration_id
      );
      if (!integration) {
        throw new Error(`Integration not found: ${args.integration_id}`);
      }
      return { integration };
    },
  },
  connect_integration: {
    name: 'connect_integration',
    description:
      'Connect an OAuth integration (requires user interaction in the browser)',
    inputSchema: {
      type: 'object',
      properties: {
        integration_id: {
          type: 'string',
          description: 'OAuth integration ID (slack, linear, notion, shopify)',
        },
        shop_domain: {
          type: 'string',
          description: 'Shopify shop domain (required for shopify)',
        },
      },
      required: ['integration_id'],
    },
    execute: async args => {
      const accountId = IntegrationsAPI.accountIdFromRoute;
      const settingsPath = `/app/accounts/${accountId}/settings/integrations`;

      if (args.integration_id === 'shopify' && args.shop_domain) {
        await IntegrationsAPI.connectShopify({ shopDomain: args.shop_domain });
        return {
          message:
            'Shopify connection initiated. Complete authorization in the browser.',
          settings_path: settingsPath,
        };
      }

      return {
        message: `Connect ${args.integration_id} from Integrations settings. OAuth requires user interaction in the browser.`,
        settings_path: settingsPath,
      };
    },
  },
  list_webhooks: {
    name: 'list_webhooks',
    description: 'List account webhooks',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await WebhooksAPI.get();
      return { webhooks: data.payload?.webhooks || data.payload || data };
    },
  },
  create_webhook: {
    name: 'create_webhook',
    description: 'Create a webhook subscription',
    inputSchema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Webhook name' },
        url: { type: 'string', description: 'Webhook URL' },
        subscriptions_json: {
          type: 'string',
          description: 'Subscribed events as a JSON array',
        },
        inbox_id: {
          type: 'number',
          description: 'Optional inbox ID for inbox-scoped webhooks',
        },
      },
      required: ['name', 'url', 'subscriptions_json'],
    },
    execute: async args => {
      const subscriptions = parseJson(
        args.subscriptions_json,
        'subscriptions_json'
      );
      const webhook = await store.dispatch('webhooks/create', {
        webhook: {
          name: args.name,
          url: args.url,
          subscriptions,
          inbox_id: args.inbox_id,
        },
      });
      return { webhook };
    },
  },
  update_webhook: {
    name: 'update_webhook',
    description: 'Update a webhook subscription',
    inputSchema: {
      type: 'object',
      properties: {
        webhook_id: { type: 'number', description: 'Webhook ID' },
        name: { type: 'string', description: 'Webhook name' },
        url: { type: 'string', description: 'Webhook URL' },
        subscriptions_json: {
          type: 'string',
          description: 'Subscribed events as a JSON array',
        },
        inbox_id: {
          type: 'number',
          description: 'Optional inbox ID',
        },
      },
      required: ['webhook_id'],
    },
    execute: async args => {
      const updateObj = {};
      if (args.name !== undefined) updateObj.name = args.name;
      if (args.url !== undefined) updateObj.url = args.url;
      if (args.inbox_id !== undefined) updateObj.inbox_id = args.inbox_id;
      if (args.subscriptions_json) {
        updateObj.subscriptions = parseJson(
          args.subscriptions_json,
          'subscriptions_json'
        );
      }

      await store.dispatch('webhooks/update', {
        id: args.webhook_id,
        ...updateObj,
      });
      return { webhook_id: args.webhook_id, updated: true };
    },
  },
  delete_webhook: {
    name: 'delete_webhook',
    description: 'Delete a webhook subscription',
    inputSchema: {
      type: 'object',
      properties: {
        webhook_id: { type: 'number', description: 'Webhook ID' },
      },
      required: ['webhook_id'],
    },
    execute: async args => {
      await store.dispatch('webhooks/delete', args.webhook_id);
      return { webhook_id: args.webhook_id, deleted: true };
    },
  },
  list_integration_hooks: {
    name: 'list_integration_hooks',
    description: 'List integration hooks, optionally filtered by app',
    inputSchema: {
      type: 'object',
      properties: {
        app_id: {
          type: 'string',
          description: 'Optional integration app ID filter',
        },
      },
    },
    execute: async args => {
      const { data } = await IntegrationsAPI.get();
      const integrations = data.payload || data;

      if (args.app_id) {
        const integration = integrations.find(
          record => record.id === args.app_id
        );
        return { integration_hooks: integration?.hooks || [] };
      }

      const hooks = integrations.flatMap(
        integration => integration.hooks || []
      );
      return { integration_hooks: hooks };
    },
  },
  create_integration_hook: {
    name: 'create_integration_hook',
    description: 'Create an integration hook',
    inputSchema: {
      type: 'object',
      properties: {
        app_id: {
          type: 'string',
          description: 'Integration app ID (e.g. openai, dialogflow)',
        },
        settings_json: {
          type: 'string',
          description: 'Integration settings as a JSON object',
        },
        inbox_id: {
          type: 'number',
          description: 'Inbox ID for inbox-scoped integrations',
        },
        status: {
          type: 'string',
          description: 'Hook status (enabled or disabled)',
        },
      },
      required: ['app_id'],
    },
    execute: async args => {
      const hookData = {
        app_id: args.app_id,
        status: args.status,
        inbox_id: args.inbox_id,
        settings: args.settings_json
          ? parseJson(args.settings_json, 'settings_json')
          : {},
      };
      await store.dispatch('integrations/createHook', hookData);
      return { app_id: args.app_id, created: true };
    },
  },
  update_integration_hook: {
    name: 'update_integration_hook',
    description: 'Update an integration hook status or settings',
    inputSchema: {
      type: 'object',
      properties: {
        hook_id: { type: 'number', description: 'Integration hook ID' },
        status: {
          type: 'string',
          description: 'Hook status (enabled or disabled)',
        },
        settings_json: {
          type: 'string',
          description: 'Integration settings as a JSON object',
        },
      },
      required: ['hook_id'],
    },
    execute: async args => {
      const hookPayload = {};
      if (args.status !== undefined) hookPayload.status = args.status;
      if (args.settings_json) {
        hookPayload.settings = parseJson(args.settings_json, 'settings_json');
      }

      const { data } = await axios.patch(
        `${IntegrationsAPI.baseUrl()}/integrations/hooks/${args.hook_id}`,
        { hook: hookPayload }
      );
      return { integration_hook: data };
    },
  },
  delete_integration_hook: {
    name: 'delete_integration_hook',
    description: 'Delete an integration hook',
    inputSchema: {
      type: 'object',
      properties: {
        hook_id: { type: 'number', description: 'Integration hook ID' },
      },
      required: ['hook_id'],
    },
    execute: async args => {
      await IntegrationsAPI.deleteHook(args.hook_id);
      return { hook_id: args.hook_id, deleted: true };
    },
  },
  list_dashboard_apps: {
    name: 'list_dashboard_apps',
    description: 'List dashboard apps configured for the account',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await DashboardAppsAPI.get();
      return { dashboard_apps: data };
    },
  },
  create_dashboard_app: {
    name: 'create_dashboard_app',
    description: 'Create a dashboard app',
    inputSchema: {
      type: 'object',
      properties: {
        title: { type: 'string', description: 'Dashboard app title' },
        content_json: {
          type: 'string',
          description: 'Dashboard app content as a JSON array of frame objects',
        },
      },
      required: ['title', 'content_json'],
    },
    execute: async args => {
      const content = parseJson(args.content_json, 'content_json');
      await store.dispatch('dashboardApps/create', {
        title: args.title,
        content,
      });
      return { title: args.title, created: true };
    },
  },
  update_dashboard_app: {
    name: 'update_dashboard_app',
    description: 'Update a dashboard app',
    inputSchema: {
      type: 'object',
      properties: {
        dashboard_app_id: {
          type: 'number',
          description: 'Dashboard app ID',
        },
        title: { type: 'string', description: 'Dashboard app title' },
        content_json: {
          type: 'string',
          description: 'Dashboard app content as a JSON array',
        },
      },
      required: ['dashboard_app_id'],
    },
    execute: async args => {
      const updateObj = {};
      if (args.title !== undefined) updateObj.title = args.title;
      if (args.content_json) {
        updateObj.content = parseJson(args.content_json, 'content_json');
      }

      await store.dispatch('dashboardApps/update', {
        id: args.dashboard_app_id,
        ...updateObj,
      });
      return { dashboard_app_id: args.dashboard_app_id, updated: true };
    },
  },
  delete_dashboard_app: {
    name: 'delete_dashboard_app',
    description: 'Delete a dashboard app',
    inputSchema: {
      type: 'object',
      properties: {
        dashboard_app_id: {
          type: 'number',
          description: 'Dashboard app ID',
        },
      },
      required: ['dashboard_app_id'],
    },
    execute: async args => {
      await store.dispatch('dashboardApps/delete', args.dashboard_app_id);
      return { dashboard_app_id: args.dashboard_app_id, deleted: true };
    },
  },
  get_billing_summary: {
    name: 'get_billing_summary',
    description: 'Get billing subscription summary for the account',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await EnterpriseAccountAPI.subscription();
      return { billing_summary: data };
    },
  },
  get_billing_limits: {
    name: 'get_billing_limits',
    description: 'Get billing usage limits for the account',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await EnterpriseAccountAPI.getLimits();
      return { billing_limits: data };
    },
  },
  get_topup_options: {
    name: 'get_topup_options',
    description: 'Get available Copilot credit top-up packages',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      const { data } = await EnterpriseAccountAPI.getTopupOptions();
      return { topup_options: data };
    },
  },
  open_billing_portal: {
    name: 'open_billing_portal',
    description:
      'Open the Stripe billing portal (requires user interaction in the browser)',
    inputSchema: {
      type: 'object',
      properties: {},
    },
    execute: async () => {
      await store.dispatch('accounts/checkout');
      return {
        message: 'Redirecting to the billing portal in the browser.',
      };
    },
  },
  purchase_copilot_credits: {
    name: 'purchase_copilot_credits',
    description:
      'Start checkout to purchase Copilot credits (requires user interaction)',
    inputSchema: {
      type: 'object',
      properties: {
        credits: {
          type: 'number',
          description: 'Number of credits to purchase',
        },
      },
      required: ['credits'],
    },
    execute: async args => {
      const { data } = await EnterpriseAccountAPI.createTopupCheckout(
        args.credits
      );
      if (data.redirect_url) {
        window.location = data.redirect_url;
      }
      return {
        message: 'Redirecting to checkout for Copilot credits.',
        redirect_url: data.redirect_url,
      };
    },
  },
  select_billing_currency: {
    name: 'select_billing_currency',
    description:
      'Select billing currency for a new account (requires billing page context)',
    inputSchema: {
      type: 'object',
      properties: {
        currency: {
          type: 'string',
          description: 'Billing currency code (e.g. usd, eur)',
        },
      },
      required: ['currency'],
    },
    execute: async args => {
      await store.dispatch('accounts/selectBillingCurrency', args.currency);
      return {
        message: `Billing currency set to ${args.currency}. Refresh billing settings to continue setup.`,
      };
    },
  },
  update_inbox_working_hours: {
    name: 'update_inbox_working_hours',
    description: 'Update inbox working hours and availability settings',
    inputSchema: {
      type: 'object',
      properties: {
        inbox_id: { type: 'number', description: 'Inbox ID' },
        working_hours_json: {
          type: 'string',
          description: 'Working hours as a JSON array of day schedules',
        },
      },
      required: ['inbox_id', 'working_hours_json'],
    },
    execute: async args => {
      const working_hours = parseJson(
        args.working_hours_json,
        'working_hours_json'
      );
      await store.dispatch('inboxes/updateInbox', {
        id: args.inbox_id,
        formData: false,
        working_hours,
        channel: {},
      });
      return { inbox_id: args.inbox_id, updated: true };
    },
  },
};

const ROUTE_TOOL_IDS = {
  '/app/accounts/:accountId/settings/labels': ['list_labels', 'create_label'],
  '/app/accounts/:accountId/settings/macros': [
    'list_macros',
    'create_macro',
    'execute_macro',
  ],
  '/app/accounts/:accountId/settings/automation': [
    'list_automation_rules',
    'create_automation_rule',
  ],
  '/app/accounts/:accountId/campaigns': ['list_campaigns', 'create_campaign'],
  '/app/accounts/:accountId/settings/integrations': [
    'list_integrations',
    'get_integration',
    'connect_integration',
    'list_webhooks',
    'create_webhook',
    'update_webhook',
    'delete_webhook',
    'list_integration_hooks',
    'create_integration_hook',
    'update_integration_hook',
    'delete_integration_hook',
    'list_dashboard_apps',
    'create_dashboard_app',
    'update_dashboard_app',
    'delete_dashboard_app',
  ],
  '/app/accounts/:accountId/settings/billing': [
    'get_billing_summary',
    'get_billing_limits',
    'get_topup_options',
    'open_billing_portal',
    'purchase_copilot_credits',
    'select_billing_currency',
  ],
  '/app/accounts/:accountId/settings/inboxes': ['update_inbox_working_hours'],
  '/app/accounts/:accountId/conversations/:conversationId': [
    'search_conversations',
    'get_conversation',
    'assign_conversation',
    'resolve_conversation',
    'add_label_to_conversation',
    'execute_macro',
  ],
};

export const normalizeRoutePath = (path, accountId) => {
  if (!path || !accountId) return path;

  return path
    .replace(`/app/accounts/${accountId}`, '/app/accounts/:accountId')
    .replace(/\/conversations\/\d+/, '/conversations/:conversationId');
};

const routePatternToRegExp = pattern =>
  new RegExp(`^${pattern.replace(/:[^/]+/g, '[^/]+')}$`);

export const getToolIdsForRoute = normalizedPath => {
  const match = Object.entries(ROUTE_TOOL_IDS).find(([pattern]) =>
    routePatternToRegExp(pattern).test(normalizedPath)
  );

  return match ? match[1] : [];
};

export const getImperativeToolDefinition = toolId =>
  IMPERATIVE_TOOL_DEFINITIONS[toolId] || null;

export const getImperativeHandler = toolId => {
  const definition = getImperativeToolDefinition(toolId);
  return definition?.execute || null;
};

export const buildImperativeToolsForRoute = (
  normalizedPath,
  capabilities = []
) => {
  const routeToolIds = getToolIdsForRoute(normalizedPath);
  const capabilityToolIds = capabilities
    .filter(
      capability =>
        capability.webmcp_mode === 'imperative' &&
        capability.exposure?.includes('webmcp')
    )
    .map(capability => capability.id);

  const toolIds = [...new Set([...routeToolIds, ...capabilityToolIds])];

  return toolIds
    .map(toolId => getImperativeToolDefinition(toolId))
    .filter(Boolean);
};
