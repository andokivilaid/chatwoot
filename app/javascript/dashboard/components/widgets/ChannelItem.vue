<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import ChannelSelector from '../ChannelSelector.vue';
import { useChannelConfig } from 'dashboard/routes/dashboard/onboarding/inbox-setup/useChannelConfig';

const props = defineProps({
  channel: {
    type: Object,
    required: true,
  },
  enabledFeatures: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits(['channelItemClick']);

const { t } = useI18n();
const { getDisabledReasonKey } = useChannelConfig();

const SETTINGS_CREDENTIAL_CHANNELS = ['facebook', 'instagram', 'tiktok'];
const FEATURE_NOT_ENABLED_KEY = 'CHANNEL_SELECTOR.DISABLED.FEATURE_NOT_ENABLED';

const isComingSoon = computed(() => {
  const { key } = props.channel;
  return key === 'voice' && !props.enabledFeatures.channel_voice;
});

const disabledReasonKey = computed(() => {
  if (Object.keys(props.enabledFeatures).length === 0) {
    return null;
  }

  if (isComingSoon.value) {
    return null;
  }

  const reason = getDisabledReasonKey(props.channel.key, {
    enabledFeatures: props.enabledFeatures,
  });

  if (!SETTINGS_CREDENTIAL_CHANNELS.includes(props.channel.key)) {
    return reason === FEATURE_NOT_ENABLED_KEY ? reason : null;
  }

  return reason;
});

const isActive = computed(
  () => !disabledReasonKey.value && !isComingSoon.value
);

const isBeta = computed(() => {
  return ['tiktok', 'voice', 'whatsapp_call'].includes(props.channel.key);
});

const hasVoiceBadge = computed(() => {
  return (
    ['voice', 'whatsapp_call'].includes(props.channel.key) &&
    !!props.enabledFeatures.channel_voice
  );
});

const disabledMessage = computed(() =>
  disabledReasonKey.value ? t(disabledReasonKey.value) : ''
);

const onItemClick = () => {
  if (isActive.value) {
    emit('channelItemClick', props.channel.key);
  }
};
</script>

<template>
  <ChannelSelector
    :title="channel.title"
    :description="channel.description"
    :icon="channel.icon"
    :is-coming-soon="isComingSoon"
    :is-beta="isBeta"
    :has-voice-badge="hasVoiceBadge"
    :disabled="!isActive"
    :disabled-message="disabledMessage"
    @click="onItemClick"
  />
</template>
