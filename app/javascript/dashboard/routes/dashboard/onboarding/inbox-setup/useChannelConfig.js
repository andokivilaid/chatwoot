import { useMapGetter } from 'dashboard/composables/store';
import { useAccount } from 'dashboard/composables/useAccount';
import { FEATURE_FLAGS } from 'dashboard/featureFlags';

const DISABLED_REASON_KEYS = {
  META_RESTRICTION: 'CHANNEL_SELECTOR.DISABLED.META_RESTRICTION',
  FACEBOOK_NOT_CONFIGURED: 'CHANNEL_SELECTOR.DISABLED.FACEBOOK_NOT_CONFIGURED',
  INSTAGRAM_NOT_CONFIGURED:
    'CHANNEL_SELECTOR.DISABLED.INSTAGRAM_NOT_CONFIGURED',
  WHATSAPP_NOT_CONFIGURED: 'CHANNEL_SELECTOR.DISABLED.WHATSAPP_NOT_CONFIGURED',
  TIKTOK_NOT_CONFIGURED: 'CHANNEL_SELECTOR.DISABLED.TIKTOK_NOT_CONFIGURED',
  GMAIL_NOT_CONFIGURED: 'CHANNEL_SELECTOR.DISABLED.GMAIL_NOT_CONFIGURED',
  OUTLOOK_NOT_CONFIGURED: 'CHANNEL_SELECTOR.DISABLED.OUTLOOK_NOT_CONFIGURED',
  FEATURE_NOT_ENABLED: 'CHANNEL_SELECTOR.DISABLED.FEATURE_NOT_ENABLED',
};

const CHANNEL_FEATURE_FLAGS = {
  website: 'channel_website',
  facebook: 'channel_facebook',
  email: 'channel_email',
  instagram: 'channel_instagram',
  tiktok: 'channel_tiktok',
  voice: 'channel_voice',
  whatsapp_call: 'channel_voice',
};

const META_CHANNEL_TYPES = ['whatsapp', 'facebook', 'instagram'];

// OAuth/SDK channels need installation-level app credentials to be usable.
// Channels without an entry (Website, Telegram, Line, …) need no installation
// credential and are always considered configured. Mirrors the availability
// checks in ChannelItem.vue.
export function useChannelConfig() {
  const globalConfig = useMapGetter('globalConfig/get');
  const {
    isCloudFeatureEnabled,
    isOnChatwootCloud,
    isMetaInboxCreationDisabled,
  } = useAccount();
  const installationConfig = window.chatwootConfig || {};

  const isWhatsappEmbeddedSignupFeatureEnabled = () =>
    !isOnChatwootCloud.value ||
    isCloudFeatureEnabled(FEATURE_FLAGS.WHATSAPP_EMBEDDED_SIGNUP_FLOW);

  const CHANNEL_CONFIGURED = {
    // WhatsApp is onboarded only via Meta embedded signup, which needs both the
    // app id (not the 'none' sentinel) and the signup configuration id.
    whatsapp: () =>
      !isMetaInboxCreationDisabled.value &&
      isWhatsappEmbeddedSignupFeatureEnabled() &&
      Boolean(installationConfig.whatsappAppId) &&
      installationConfig.whatsappAppId !== 'none' &&
      Boolean(installationConfig.whatsappConfigurationId),
    facebook: () =>
      !isMetaInboxCreationDisabled.value && Boolean(installationConfig.fbAppId),
    instagram: () =>
      !isMetaInboxCreationDisabled.value &&
      Boolean(installationConfig.instagramAppId) &&
      isCloudFeatureEnabled(FEATURE_FLAGS.CHANNEL_INSTAGRAM),
    tiktok: () => Boolean(installationConfig.tiktokAppId),
    gmail: () => Boolean(installationConfig.googleOAuthClientId),
    outlook: () => Boolean(globalConfig.value.azureAppId),
  };

  const isConfigured = type => CHANNEL_CONFIGURED[type]?.() ?? true;

  const getDisabledReasonKey = (type, { enabledFeatures = null } = {}) => {
    if (enabledFeatures) {
      const featureFlag = CHANNEL_FEATURE_FLAGS[type];
      if (
        featureFlag &&
        Object.keys(enabledFeatures).length > 0 &&
        !enabledFeatures[featureFlag]
      ) {
        return DISABLED_REASON_KEYS.FEATURE_NOT_ENABLED;
      }
    }

    if (isConfigured(type)) return null;

    if (
      isMetaInboxCreationDisabled.value &&
      META_CHANNEL_TYPES.includes(type)
    ) {
      return DISABLED_REASON_KEYS.META_RESTRICTION;
    }

    if (
      type === 'instagram' &&
      !isCloudFeatureEnabled(FEATURE_FLAGS.CHANNEL_INSTAGRAM)
    ) {
      return DISABLED_REASON_KEYS.FEATURE_NOT_ENABLED;
    }

    if (
      type === 'whatsapp' &&
      isOnChatwootCloud.value &&
      !isWhatsappEmbeddedSignupFeatureEnabled()
    ) {
      return DISABLED_REASON_KEYS.FEATURE_NOT_ENABLED;
    }

    const reasonByType = {
      whatsapp: DISABLED_REASON_KEYS.WHATSAPP_NOT_CONFIGURED,
      facebook: DISABLED_REASON_KEYS.FACEBOOK_NOT_CONFIGURED,
      instagram: DISABLED_REASON_KEYS.INSTAGRAM_NOT_CONFIGURED,
      tiktok: DISABLED_REASON_KEYS.TIKTOK_NOT_CONFIGURED,
      gmail: DISABLED_REASON_KEYS.GMAIL_NOT_CONFIGURED,
      outlook: DISABLED_REASON_KEYS.OUTLOOK_NOT_CONFIGURED,
    };

    return reasonByType[type] || null;
  };

  const isChannelAvailable = (type, options = {}) =>
    !getDisabledReasonKey(type, options);

  return { isConfigured, getDisabledReasonKey, isChannelAvailable };
}
