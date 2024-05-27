module.exports = {
  extends: "./.eslintrc.js",
  rules: {
    "indent": ["error", 2, { "SwitchCase": 1 }],
    "react/jsx-indent": ["error", 2],
    "react/jsx-indent-props": ["error", 2],
    "array-bracket-spacing": ["error", "never"],
    "object-curly-spacing": ["error", "always"],
    "react/jsx-curly-spacing": ["error", { "when": "never", "children": { "when": "always" } }],
  }
};
