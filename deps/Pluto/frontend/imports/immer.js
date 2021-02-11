import immer, { setAutoFreeze } from "/offline_assets/immer.esm.js"

export default immer

// we have some Editor.setState functions that use immer, so Editor.this.state becomes an "immer immutable frozen object". But we also have some Editor.setState functions that don't use immer, and they try to _mutate_ Editor.this.state. This gives errors like https://github.com/immerjs/immer/issues/576

// The solution is to tell immer not to create immutable objects

setAutoFreeze(false)
