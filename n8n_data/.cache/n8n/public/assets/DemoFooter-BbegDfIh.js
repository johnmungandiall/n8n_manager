import LogsPanel from "./LogsPanel-CaVtvitq.js";
import { d as defineComponent, T as useWorkflowsStore, x as computed, e as createBlock, f as createCommentVNode, g as openBlock } from "./index-Cb_lQ9m_.js";
import "./RunData-D-o34apM.js";
import "./FileSaver.min-C7cViz61.js";
import "./useExecutionHelpers-Ae2t-uj6.js";
import "./useKeybindings-BZXwu-r0.js";
const _sfc_main = /* @__PURE__ */ defineComponent({
  __name: "DemoFooter",
  setup(__props) {
    const workflowsStore = useWorkflowsStore();
    const hasExecutionData = computed(() => workflowsStore.workflowExecutionData);
    return (_ctx, _cache) => {
      return hasExecutionData.value ? (openBlock(), createBlock(LogsPanel, {
        key: 0,
        "is-read-only": true
      })) : createCommentVNode("", true);
    };
  }
});
export {
  _sfc_main as default
};
