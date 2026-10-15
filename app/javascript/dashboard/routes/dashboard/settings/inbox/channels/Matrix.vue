<script setup>
import { computed, ref } from 'vue';
import { useStore } from 'vuex';
import { useRouter } from 'vue-router';
import { useI18n } from 'vue-i18n';
import { useVuelidate } from '@vuelidate/core';
import { required, url } from '@vuelidate/validators';
import { useAlert } from 'dashboard/composables';
import PageHeader from '../../SettingsSubPageHeader.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';

const store = useStore();
const router = useRouter();
const { t } = useI18n();

const inboxName = ref('');
const homeserverUrl = ref('');
const userId = ref('');

const isMatrixUserId = value => /^@[^:\s]+:\S+$/.test(value);

const v$ = useVuelidate(
  {
    inboxName: { required },
    homeserverUrl: { required, url },
    userId: { required, isMatrixUserId },
  },
  { inboxName, homeserverUrl, userId }
);

const uiFlags = computed(() => store.getters['inboxes/getUIFlags']);

const createChannel = async () => {
  v$.value.$touch();
  if (v$.value.$invalid) return;

  try {
    const matrixChannel = await store.dispatch('inboxes/createChannel', {
      name: inboxName.value,
      channel: {
        type: 'matrix',
        homeserver_url: homeserverUrl.value.trim(),
        user_id: userId.value.trim(),
      },
    });

    router.replace({
      name: 'settings_inboxes_add_agents',
      params: { page: 'new', inbox_id: matrixChannel.id },
    });
  } catch (error) {
    useAlert(
      error.message || t('INBOX_MGMT.ADD.MATRIX_CHANNEL.API.ERROR_MESSAGE')
    );
  }
};
</script>

<template>
  <div class="h-full w-full p-6 col-span-6">
    <PageHeader
      :header-title="$t('INBOX_MGMT.ADD.MATRIX_CHANNEL.TITLE')"
      :header-content="$t('INBOX_MGMT.ADD.MATRIX_CHANNEL.DESC')"
    />
    <form class="flex flex-col mx-0" @submit.prevent="createChannel">
      <label :class="{ error: v$.inboxName.$error }">
        {{ $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.INBOX_NAME.LABEL') }}
        <input
          v-model="inboxName"
          type="text"
          :placeholder="
            $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.INBOX_NAME.PLACEHOLDER')
          "
          @blur="v$.inboxName.$touch"
        />
      </label>

      <label :class="{ error: v$.homeserverUrl.$error }">
        {{ $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.HOMESERVER_URL.LABEL') }}
        <input
          v-model="homeserverUrl"
          type="url"
          :placeholder="
            $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.HOMESERVER_URL.PLACEHOLDER')
          "
          @blur="v$.homeserverUrl.$touch"
        />
        <span v-if="v$.homeserverUrl.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.HOMESERVER_URL.ERROR') }}
        </span>
      </label>
      <p class="help-text">
        {{ $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.HOMESERVER_URL.SUBTITLE') }}
      </p>

      <label :class="{ error: v$.userId.$error }">
        {{ $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.USER_ID.LABEL') }}
        <input
          v-model="userId"
          type="text"
          :placeholder="$t('INBOX_MGMT.ADD.MATRIX_CHANNEL.USER_ID.PLACEHOLDER')"
          @blur="v$.userId.$touch"
        />
        <span v-if="v$.userId.$error" class="message">
          {{ $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.USER_ID.ERROR') }}
        </span>
      </label>
      <p class="help-text">
        {{ $t('INBOX_MGMT.ADD.MATRIX_CHANNEL.USER_ID.SUBTITLE') }}
      </p>

      <div class="w-full mt-4">
        <NextButton
          :is-loading="uiFlags.isCreating"
          type="submit"
          solid
          blue
          :label="$t('INBOX_MGMT.ADD.MATRIX_CHANNEL.SUBMIT_BUTTON')"
        />
      </div>
    </form>
  </div>
</template>
