const resolveModelContext = () => {
  if (typeof document !== 'undefined' && document.modelContext) {
    return document.modelContext;
  }

  if (typeof navigator !== 'undefined' && navigator.modelContext) {
    return navigator.modelContext;
  }

  return null;
};

class WebMcpRegistry {
  constructor() {
    this.registeredTools = new Map();
  }

  // eslint-disable-next-line class-methods-use-this
  isSupported() {
    return Boolean(resolveModelContext());
  }

  // eslint-disable-next-line class-methods-use-this
  getModelContext() {
    return resolveModelContext();
  }

  async registerTool(tool) {
    const modelContext = this.getModelContext();
    if (!modelContext) return null;

    await modelContext.registerTool(tool);
    this.registeredTools.set(tool.name, tool);
    return tool.name;
  }

  async unregisterTool(name) {
    const modelContext = this.getModelContext();
    if (modelContext?.unregisterTool) {
      await modelContext.unregisterTool(name);
    }

    this.registeredTools.delete(name);
  }

  async unregisterAll() {
    const toolNames = [...this.registeredTools.keys()];
    await Promise.all(toolNames.map(name => this.unregisterTool(name)));
  }

  async executeTool(name, args = {}) {
    const localTool = this.registeredTools.get(name);
    if (localTool?.execute) {
      return localTool.execute(args);
    }

    const modelContext = this.getModelContext();
    if (modelContext?.executeTool) {
      return modelContext.executeTool(name, args);
    }

    if (modelContext?.callTool) {
      return modelContext.callTool(name, args);
    }

    throw new Error(`Tool "${name}" is not registered`);
  }

  getRegisteredToolNames() {
    return [...this.registeredTools.keys()];
  }
}

export const webMcpRegistry = new WebMcpRegistry();

export const isWebMcpSupported = () => webMcpRegistry.isSupported();

export const getModelContext = () => webMcpRegistry.getModelContext();
