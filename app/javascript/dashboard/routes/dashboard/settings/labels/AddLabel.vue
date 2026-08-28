<script>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import validations, { getLabelTitleErrorMessage } from './validations';
import { getRandomColor } from 'dashboard/helper/labelColor';
import { useVuelidate } from '@vuelidate/core';
import {
  fetchCapabilities,
  getCapabilityById,
} from 'dashboard/helper/capabilities';

import NextButton from 'dashboard/components-next/button/Button.vue';
import WebMcpForm from 'dashboard/components-next/webmcp/WebMcpForm.vue';

export default {
  components: {
    NextButton,
    WebMcpForm,
  },
  props: {
    prefillTitle: {
      type: String,
      default: '',
    },
  },
  emits: ['close'],
  setup() {
    const route = useRoute();
    const capability = ref(null);

    onMounted(async () => {
      await fetchCapabilities(route.params.accountId);
      capability.value = getCapabilityById('create_label');
    });

    return { v$: useVuelidate(), capability };
  },
  data() {
    return {
      color: '#000',
      description: '',
      title: '',
      showOnSidebar: true,
    };
  },
  validations,
  computed: {
    ...mapGetters({
      uiFlags: 'labels/getUIFlags',
    }),
    labelTitleErrorMessage() {
      const errorMessage = getLabelTitleErrorMessage(this.v$);
      return this.$t(errorMessage);
    },
  },
  mounted() {
    this.color = getRandomColor();
    this.title = this.prefillTitle.toLowerCase();
  },
  methods: {
    onClose() {
      this.$emit('close');
    },
    buildLabelPayload(formData = {}) {
      return {
        color: formData.color || this.color,
        description: formData.description ?? this.description,
        title: String(formData.title || this.title).toLowerCase(),
        show_on_sidebar:
          formData.show_on_sidebar === undefined
            ? this.showOnSidebar
            : ['true', 'on', '1', true].includes(formData.show_on_sidebar),
      };
    },
    async executeCreateLabel(formData = {}) {
      try {
        const payload = this.buildLabelPayload(formData);
        await this.$store.dispatch('labels/create', payload);
        useAlert(this.$t('LABEL_MGMT.ADD.API.SUCCESS_MESSAGE'));
        this.onClose();
        return { success: true, label: payload };
      } catch (error) {
        const errorMessage =
          error.message || this.$t('LABEL_MGMT.ADD.API.ERROR_MESSAGE');
        useAlert(errorMessage);
        throw error;
      }
    },
    async addLabel() {
      await this.executeCreateLabel();
    },
  },
};
</script>

<template>
  <div class="flex flex-col h-auto overflow-auto">
    <woot-modal-header
      :header-title="$t('LABEL_MGMT.ADD.TITLE')"
      :header-content="$t('LABEL_MGMT.ADD.DESC')"
    />
    <WebMcpForm
      :capability="capability"
      :execute-fn="executeCreateLabel"
      class="flex flex-wrap mx-0"
      @submit="addLabel"
    >
      <woot-input
        v-model="title"
        :class="{ error: v$.title.$error }"
        class="w-full label-name--input"
        :label="$t('LABEL_MGMT.FORM.NAME.LABEL')"
        :placeholder="$t('LABEL_MGMT.FORM.NAME.PLACEHOLDER')"
        :error="labelTitleErrorMessage"
        data-testid="label-title"
        data-webmcp-param="title"
        @input="v$.title.$touch"
        @blur="v$.title.$touch"
      />

      <woot-input
        v-model="description"
        :class="{ error: v$.description.$error }"
        class="w-full"
        :label="$t('LABEL_MGMT.FORM.DESCRIPTION.LABEL')"
        :placeholder="$t('LABEL_MGMT.FORM.DESCRIPTION.PLACEHOLDER')"
        data-testid="label-description"
        data-webmcp-param="description"
        @input="v$.description.$touch"
        @blur="v$.description.$touch"
      />

      <div class="w-full">
        <label>
          {{ $t('LABEL_MGMT.FORM.COLOR.LABEL') }}
          <woot-color-picker v-model="color" />
        </label>
        <input type="hidden" :value="color" data-webmcp-param="color" />
      </div>
      <div class="flex items-center w-full gap-2">
        <input
          v-model="showOnSidebar"
          type="checkbox"
          :value="true"
          data-webmcp-param="show_on_sidebar"
        />
        <label for="conversation_creation">
          {{ $t('LABEL_MGMT.FORM.SHOW_ON_SIDEBAR.LABEL') }}
        </label>
      </div>
      <div class="flex items-center justify-end w-full gap-2 px-0 py-2">
        <NextButton
          faded
          slate
          type="reset"
          :label="$t('LABEL_MGMT.FORM.CANCEL')"
          @click.prevent="onClose"
        />
        <NextButton
          type="submit"
          data-testid="label-submit"
          :label="$t('LABEL_MGMT.FORM.CREATE')"
          :disabled="v$.title.$invalid || uiFlags.isCreating"
          :is-loading="uiFlags.isCreating"
        />
      </div>
    </WebMcpForm>
  </div>
</template>

<style lang="scss" scoped>
// Label API supports only lowercase letters
.label-name--input {
  :deep(input) {
    @apply lowercase;
  }
}
</style>
