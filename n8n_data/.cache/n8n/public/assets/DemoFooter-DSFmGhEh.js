import LogsPanel from "./LogsPanel-B16caVIK.js";
import { d as defineComponent, T as useWorkflowsStore, x as computed, e as createBlock, f as createCommentVNode, g as openBlock } from "./index-CKxPg00R.js";
import "./RunData-Ccq7yyEj.js";
import "./FileSaver.min-Ba1NW2qr.js";
import "./useExecutionHelpers-C_9FYOFV.js";
import "./canvas-CIm8w6n1.js";
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
