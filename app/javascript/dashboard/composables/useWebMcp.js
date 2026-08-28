import { onUnmounted, ref } from 'vue';
import {
  webMcpRegistry,
  isWebMcpSupported,
  getModelContext,
} from 'dashboard/helper/webmcp/registry';
import {
  buildInputSchemaFromParams,
  executeCapability,
} from 'dashboard/helper/capabilities';

export { isWebMcpSupported, getModelContext };

export const registerDeclarativeForm = (
  formElement,
  { onActivated, onCancel, toolName } = {}
) => {
  if (!formElement) {
    return () => {};
  }

  const handleToolActivated = event => {
    if (toolName && event.toolName !== toolName) return;
    onActivated?.(event);
  };

  const handleToolCancel = event => {
    if (toolName && event.toolName !== toolName) return;
    onCancel?.(event);
  };

  window.addEventListener('toolactivated', handleToolActivated);
  window.addEventListener('toolcancel', handleToolCancel);

  return () => {
    window.removeEventListener('toolactivated', handleToolActivated);
    window.removeEventListener('toolcancel', handleToolCancel);
  };
};

export function useWebMcp() {
  const supported = isWebMcpSupported();
  const registeredTools = ref([]);

  const registerTool = async tool => {
    const toolName = await webMcpRegistry.registerTool(tool);
    if (toolName) {
      registeredTools.value = [...registeredTools.value, toolName];
    }
    return toolName;
  };

  const registerCapabilityTool = async (capability, executeFn) => {
    if (!capability?.id) return null;

    return registerTool({
      name: capability.id,
      description: capability.description || capability.title || capability.id,
      inputSchema:
        capability.input_schema ||
        buildInputSchemaFromParams(capability.params),
      execute: executeFn,
    });
  };

  const unregisterTool = async name => {
    await webMcpRegistry.unregisterTool(name);
    registeredTools.value = registeredTools.value.filter(
      toolName => toolName !== name
    );
  };

  const unregisterAll = async () => {
    await Promise.all(registeredTools.value.map(name => unregisterTool(name)));
  };

  const executeTool = async (name, args = {}) => executeCapability(name, args);

  onUnmounted(() => {
    unregisterAll();
  });

  return {
    supported,
    registeredTools,
    getModelContext,
    registerTool,
    registerCapabilityTool,
    unregisterTool,
    unregisterAll,
    registerDeclarativeForm,
    executeTool,
    executeCapability,
  };
}
