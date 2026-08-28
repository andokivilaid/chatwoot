import {
  fetchCapabilitiesForRoute,
  registerRouteCapabilities,
} from 'dashboard/helper/capabilities';
import { isWebMcpSupported } from 'dashboard/helper/webmcp/registry';

export default {
  install(_app, { router } = {}) {
    if (!router || !isWebMcpSupported()) return;

    let unregisterRouteTools = null;

    router.afterEach(async to => {
      if (unregisterRouteTools) {
        await unregisterRouteTools();
        unregisterRouteTools = null;
      }

      const accountId = to.params.accountId;
      if (!accountId || !to.path.includes('/app/accounts/')) return;

      const capabilities = await fetchCapabilitiesForRoute({
        route: to.path,
        accountId,
      });

      unregisterRouteTools = await registerRouteCapabilities({
        route: to.path,
        accountId,
        capabilities,
      });
    });
  },
};
