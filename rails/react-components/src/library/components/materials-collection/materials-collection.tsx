//
// NOTE: this is direct conversion from the portal materials-collection coffeescript
// HOWEVER: there is already a root level materials-collection library that is used in the library
//

import React from "react";

import SMaterialsList from "../search/materials-list";
import { loadMaterialsCollection } from "../../helpers/materials-collection-cache";

const shuffle = function (a: any) {
  let idx = a.length;
  while (--idx > 0) {
    // eslint-disable-next-line no-bitwise
    const j = ~~(Math.random() * (idx + 1));
    const t = a[j];
    a[j] = a[idx];
    a[idx] = t;
  }
  return a;
};

export default class MaterialsCollection extends React.Component<any, any> {
  static defaultProps = {
    randomize: false,
    limit: Infinity,
    header: null,
    // Optional callback executed when materials collection is downloaded
    onDataLoad: null
  };

  mounted: any;
  constructor (props: any) {
    super(props);
    this.state = {
      materials: [],
      truncated: true
    };
    this.mounted = false;
    this.toggle = this.toggle.bind(this);
  }

  componentDidMount () {
    this.mounted = true;
    const { randomize, onDataLoad } = this.props;
    loadMaterialsCollection(this.props.collection, ({
      materials
    }: any) => {
      if (randomize) {
        materials = shuffle(materials);
      }
      if (onDataLoad) {
        onDataLoad(materials);
      }
      if (this.mounted) {
        this.setState({ materials });
      }
    });
  }

  toggle (e: any) {
    this.setState((prevState: any) => ({ truncated: !prevState.truncated }));
    e.preventDefault();
  }

  getMaterialsList () {
    if (this.state.truncated) {
      return this.state.materials.slice(0, this.props.limit);
    } else {
      return this.state.materials;
    }
  }

  renderTruncationToggle () {
    if (this.state.materials.length <= this.props.limit) {
      return;
    }
    const chevron = this.state.truncated ? "down" : "up";
    const text = this.state.truncated ? " show all materials" : " show less";
    return (
      <a className="mc-truncate" onClick={this.toggle} href="">
        <i className={`fa fa-chevron-${chevron}`} />
        <span className="mc-truncate-text">{ text }</span>
      </a>
    );
  }

  render () {
    const headerVisible = this.props.header && (this.state.materials.length > 0);
    return (
      <div>
        { headerVisible
          ? <h1 className="collection-header">{ this.props.header }</h1>
          : undefined }
        <SMaterialsList materials={this.getMaterialsList()} />
        { this.renderTruncationToggle() }
      </div>
    );
  }
}
