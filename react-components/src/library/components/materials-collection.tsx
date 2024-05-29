import React from "react";
import Component from "../helpers/component";
import shuffleArray from "../helpers/shuffle-array";
import stemFinderResult from "./stem-finder-result";
import portalObjectHelpers from "../helpers/portal-object-helpers";
import { loadMaterialsCollection } from "../helpers/materials-collection-cache";

const MaterialsCollection = Component({
  getInitialState () {
    return {
      materials: [],
      loadedData: false
    };
  },

  getDefaultProps () {
    return {
      showTeacherResourcesButton: true
    };
  },

  UNSAFE_componentWillMount () {
    loadMaterialsCollection(this.props.collection, function (data: any) {
      let materials = data.materials;
      if (this.props.randomize) {
        materials = shuffleArray(materials);
      }
      if (this.props.featured) {
        // props.featured is the ID of the material we
        // wish to insert at the start of the list
        const featuredID = this.props.featured;
        const sortFeatured = function (a: any, b: any) {
          if (a.id === featuredID) return -1;
          if (b.id === featuredID) return 1;
          return 0;
        };
        materials.sort(sortFeatured);
      }
      this.setState({ materials, loadedData: true });
    }.bind(this));
  },

  componentDidMount () {
    const checkForDataLoaded = () => {
      if (!this.props.onDataLoad) {
        return;
      }
      if (this.state.loadedData) {
        this.props.onDataLoad(this.state.materials);
      } else {
        setTimeout(checkForDataLoaded, 10);
      }
    };

    checkForDataLoaded();
  },

  render () {
    const showTeacherResourcesButton = this.props.showTeacherResourcesButton;

    if (this.state.materials.length === 0) {
      return null;
    }

    return (
      <div className={"portal-pages-finder-materials-collection"}>
        { this.state.materials.map(function (material: any, i: any) {
          portalObjectHelpers.processResource(material);
          return stemFinderResult({ key: i, resource: material, showTeacherResourcesButton });
        }) }
      </div>
    );
  }
});

export default MaterialsCollection;
