<script setup>
import {
  computed,
  nextTick,
  onBeforeUnmount,
  onMounted,
  ref,
  useAttrs,
  watch,
} from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { getParamDescription } from 'dashboard/helper/capabilities';
import { registerDeclarativeForm } from 'dashboard/composables/useWebMcp';

const props = defineProps({
  capability: {
    type: Object,
    default: null,
  },
  executeFn: {
    type: Function,
    default: null,
  },
  toolName: {
    type: String,
    default: '',
  },
  toolDescription: {
    type: String,
    default: '',
  },
  autoSubmit: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits(['submit', 'toolActivated', 'toolCancel']);

const attrs = useAttrs();
const { t } = useI18n();
const formRef = ref(null);
let cleanupDeclarativeListeners = null;

const resolvedToolName = computed(
  () => props.capability?.id || props.toolName || ''
);

const resolvedToolDescription = computed(() => {
  if (props.toolDescription) return props.toolDescription;
  if (props.capability?.description) return props.capability.description;
  if (props.capability?.title) return props.capability.title;
  return resolvedToolName.value;
});

const isDeclarative = computed(
  () =>
    Boolean(resolvedToolName.value && resolvedToolDescription.value) &&
    props.capability?.webmcp_mode !== 'imperative'
);

const syncWebMcpFieldMetadata = () => {
  if (!formRef.value) return;

  formRef.value.querySelectorAll('[data-webmcp-param]').forEach(element => {
    const paramName = element.getAttribute('data-webmcp-param');
    if (!paramName) return;

    const control = element.matches('input, select, textarea')
      ? element
      : element.querySelector('input, select, textarea') || element;

    if (!control.getAttribute('name')) {
      control.setAttribute('name', paramName);
    }

    const paramDescription =
      control.getAttribute('data-webmcp-param-description') ||
      element.getAttribute('data-webmcp-param-description') ||
      getParamDescription(props.capability, paramName);

    if (paramDescription) {
      control.setAttribute('toolparamdescription', paramDescription);
    }
  });
};

const collectFormData = event => {
  const payload = {};

  if (!event?.target) return payload;

  const formData = new FormData(event.target);
  formData.forEach((value, key) => {
    payload[key] = value;
  });

  event.target.querySelectorAll('[data-webmcp-param]').forEach(element => {
    const paramName = element.getAttribute('data-webmcp-param');
    if (!paramName) return;

    const control = element.matches('input, select, textarea')
      ? element
      : element.querySelector('input, select, textarea') || element;

    if (control.type === 'checkbox') {
      payload[paramName] = control.checked;
    } else {
      payload[paramName] = control.value;
    }
  });

  return payload;
};

const onSubmit = async event => {
  const formData = collectFormData(event);

  if (event?.agentInvoked && props.executeFn) {
    event.preventDefault();
    event.respondWith?.(
      Promise.resolve(props.executeFn(formData))
        .then(result => result ?? { success: true })
        .catch(error => ({
          error: error?.message || t('WEBMCP.EXECUTION_ERROR'),
        }))
    );
    return;
  }

  event.preventDefault();
  emit('submit', event);
};

const handleToolActivated = event => {
  emit('toolActivated', event);
  useAlert(
    t('WEBMCP.TOOL_ACTIVATED', {
      tool: event.toolName || resolvedToolName.value,
    })
  );
};

const handleToolCancel = event => {
  emit('toolCancel', event);
  useAlert(
    t('WEBMCP.TOOL_CANCELLED', {
      tool: event.toolName || resolvedToolName.value,
    })
  );
};

onMounted(() => {
  nextTick(() => {
    syncWebMcpFieldMetadata();

    if (!isDeclarative.value || !formRef.value) return;

    cleanupDeclarativeListeners = registerDeclarativeForm(formRef.value, {
      toolName: resolvedToolName.value,
      onActivated: handleToolActivated,
      onCancel: handleToolCancel,
    });
  });
});

watch(
  () => [props.capability, resolvedToolName.value],
  () => nextTick(syncWebMcpFieldMetadata),
  { deep: true }
);

onBeforeUnmount(() => {
  cleanupDeclarativeListeners?.();
});
</script>

<template>
  <form
    ref="formRef"
    :toolname="isDeclarative ? resolvedToolName : undefined"
    :tooldescription="isDeclarative ? resolvedToolDescription : undefined"
    :toolautosubmit="isDeclarative && autoSubmit ? true : undefined"
    v-bind="attrs"
    @submit="onSubmit"
  >
    <slot :param-description="name => getParamDescription(capability, name)" />
  </form>
</template>
