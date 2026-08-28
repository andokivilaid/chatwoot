/* global axios */
import ApiClient from '../ApiClient';

class Capabilities extends ApiClient {
  constructor() {
    super('captain/capabilities', { accountScoped: true });
  }

  get({ route } = {}) {
    return axios.get(this.url, {
      params: {
        route,
      },
    });
  }
}

export default new Capabilities();
