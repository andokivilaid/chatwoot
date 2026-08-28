<script>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { useVuelidate } from '@vuelidate/core';
import { required, minLength } from '@vuelidate/validators';
import { useAlert } from 'dashboard/composables';
import {
  fetchCapabilities,
  getCapabilityById,
} from 'dashboard/helper/capabilities';

import NextButton from 'dashboard/components-next/button/Button.vue';
import Modal from '../../../../components/Modal.vue';
import WootMessageEditor from 'dashboard/components/widgets/WootWriter/Editor.vue';
import WebMcpForm from 'dashboard/components-next/webmcp/WebMcpForm.vue';

export default {
  name: 'AddCanned',
  components: {
    NextButton,
    Modal,
    WootMessageEditor,
    WebMcpForm,
  },
  props: {
    responseContent: {
      type: String,
      default: '',
    },
    onClose: {
      type: Function,
      default: () => {},
    },
  },
  setup() {
    const route = useRoute();
    const capability = ref(null);

    onMounted(async () => {
      await fetchCapabilities(route.params.accountId);
      capability.value = getCapabilityById('create_canned_response');
    });

    return { v$: useVuelidate(), capability };
  },
  data() {
    return {
      shortCode: '',
      content: this.responseContent || '',
      addCanned: {
        showLoading: false,
        message: '',
      },
      show: true,
    };
  },
  validations: {
    shortCode: {
      required,
      minLength: minLength(2),
    },
    content: {
      required,
    },
  },
  methods: {
    resetForm() {
      this.shortCode = '';
      this.content = '';
      this.v$.shortCode.$reset();
      this.v$.content.$reset();
    },
    buildCannedPayload(formData = {}) {
      return {
        short_code: formData.short_code || this.shortCode,
        content: formData.content || this.content,
      };
    },
    async executeCreateCanned(formData = {}) {
      this.addCanned.showLoading = true;

      try {
        const payload = this.buildCannedPayload(formData);
        await this.$store.dispatch('createCannedResponse', payload);
        this.addCanned.showLoading = false;
        useAlert(this.$t('CANNED_MGMT.ADD.API.SUCCESS_MESSAGE'));
        this.resetForm();
        this.onClose();
        return { success: true, cannedResponse: payload };
      } catch (error) {
        this.addCanned.showLoading = false;
        const errorMessage =
          error?.message || this.$t('CANNED_MGMT.ADD.API.ERROR_MESSAGE');
        useAlert(errorMessage);
        throw error;
      }
    },
    addCannedResponse() {
      this.executeCreateCanned();
    },
  },
};
</script>

<template>
  <Modal v-model:show="show" :on-close="onClose">
    <div class="flex flex-col h-auto overflow-auto">
      <woot-modal-header
        :header-title="$t('CANNED_MGMT.ADD.TITLE')"
        :header-content="$t('CANNED_MGMT.ADD.DESC')"
      />
      <WebMcpForm
        :capability="capability"
        :execute-fn="executeCreateCanned"
        class="flex flex-col w-full"
        @submit="addCannedResponse"
      >
        <div class="w-full">
          <label :class="{ error: v$.shortCode.$error }">
            {{ $t('CANNED_MGMT.ADD.FORM.SHORT_CODE.LABEL') }}
            <input
              v-model="shortCode"
              type="text"
              data-webmcp-param="short_code"
              :placeholder="$t('CANNED_MGMT.ADD.FORM.SHORT_CODE.PLACEHOLDER')"
              @blur="v$.shortCode.$touch"
            />
          </label>
        </div>

        <div class="w-full">
          <label :class="{ error: v$.content.$error }">
            {{ $t('CANNED_MGMT.ADD.FORM.CONTENT.LABEL') }}
          </label>
          <div class="editor-wrap">
            <WootMessageEditor
              v-model="content"
              class="message-editor [&>div]:px-1"
              :class="{ editor_warning: v$.content.$error }"
              channel-type="Context::Default"
              enable-variables
              :enable-canned-responses="false"
              :placeholder="$t('CANNED_MGMT.ADD.FORM.CONTENT.PLACEHOLDER')"
              @blur="v$.content.$touch"
            />
          </div>
          <input type="hidden" :value="content" data-webmcp-param="content" />
        </div>
        <div class="flex flex-row justify-end w-full gap-2 px-0 py-2">
          <NextButton
            faded
            slate
            type="reset"
            :label="$t('CANNED_MGMT.ADD.CANCEL_BUTTON_TEXT')"
            @click.prevent="onClose"
          />
          <NextButton
            type="submit"
            :label="$t('CANNED_MGMT.ADD.FORM.SUBMIT')"
            :disabled="
              v$.content.$invalid ||
              v$.shortCode.$invalid ||
              addCanned.showLoading
            "
            :is-loading="addCanned.showLoading"
          />
        </div>
      </WebMcpForm>
    </div>
  </Modal>
</template>

<style scoped lang="scss">
:deep(.ProseMirror-menubar) {
  @apply hidden;
}

:deep(.ProseMirror-woot-style) {
  @apply min-h-[12.5rem];
}
</style>
