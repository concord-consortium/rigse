import React from "react";
import createReactClass from "create-react-class";

// This was converted from a React 15 mixin to a high-order component (HOC)
//
// Fetches remote data when component is visible (when @props.visible == true).
// Data is saved under @state[@dataStateKey].
// Client class has to define:
//  - .dataUrl property (string)
//  - .dataStateKey property (string), name of the state key under which data is saved
// but it can also define:
//  - .requestParams property (hash), argument of jQuery.ajax
//  - .processData() (method), it can process raw AJAX response before state is updated

export default function MBFetchDataHOC (WrappedComponent: any, optionsFn: any) {
  const MBFetchData = createReactClass({
    getInitialState () {
      const state: any = {};
      const { dataStateKey } = optionsFn();
      state[dataStateKey] = null;
      return state;
    },

    componentDidMount () {
      // Download data only if component is visibile.
      this.mounted = true;
      if (this.props.visible) {
        this.fetchData();
      }
    },

    componentWillUnmount () {
      this.mounted = false;
    },

    UNSAFE_componentWillReceiveProps (nextProps: any) {
      // Download data only if component is going to be visibile.
      if (nextProps.visible) {
        this.fetchData();
      }
    },

    fetchData () {
      const { dataUrl, dataStateKey, requestParams, processData } = optionsFn();

      // Don't download data if it's been already done.
      if (this.state[dataStateKey] != null) {
        return;
      }
      const params = (requestParams != null) ? requestParams.call(this) : {};
      jQuery.ajax({
        url: dataUrl,
        data: params,
        dataType: "json",
        success: data => {
          if (this.mounted) {
            const newState: any = {};
            // Use processData method if defined.
            newState[dataStateKey] = (processData != null) ? processData.call(this, data) : data;
            this.setState(newState);
          }
        }
      });
    },

    archive (materialId: any, archiveUrl: any) {
      if (!this.state.collectionsData) {
        return;
      }
      // TODO: this uses normal requests instead of JSON
      return jQuery.ajax({
        url: archiveUrl,
        success: data => {
          return this.setState((prevState: any) => {
            const newState = prevState.collectionsData.map((d: any) => {
              const copy = { ...d };
              copy.materials = d.materials.filter((m: any) => m.id !== materialId);
              return copy;
            });
            return { collectionsData: newState };
          });
        }
      });
    },

    archiveSingle (materialId: any, archiveUrl: any) {
      if (!this.state.materials) {
        return;
      }
      // TODO: this uses normal requests instead of JSON
      return jQuery.ajax({
        url: archiveUrl,
        success: data => {
          return this.setState((prevState: any) => {
            const newState = prevState.materials.filter((m: any) => m.id !== materialId);
            return { materials: newState };
          });
        }
      });
    },

    render () {
      // Use JSX spread syntax to pass all props and state down automatically.
      return <WrappedComponent {...this.props} {...this.state} archive={this.archive} archiveSingle={this.archiveSingle} />;
    }
  });

  MBFetchData.displayName = "MBFetchDataHOC";
  return MBFetchData;
}
