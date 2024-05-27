import React from "react";

import SPaginationInfo from "./pagination-info";
import SPagination from "./pagination";
import SMaterialsList from "./materials-list";

export default class SearchResultGroup extends React.Component<any, any> {
  materialType: any;
  pageParam: any;
  constructor (props: any) {
    super(props);
    this.state = { loading: false, ...this.props };
    this.onPaginationSelect = this.onPaginationSelect.bind(this);
    this.updateState = this.updateState.bind(this);
  }

  onPaginationSelect (page: any) {
    if (page !== this.state.group.pagination.current_page) {
      jQuery(`#${this.pageParam}`).val(page);
      let query = jQuery("#material_search_form").serialize();

      window.updateSearchUrl(query);

      // strip out all material_types[] params
      query = query.replace(/(^|&)material_types(\[|%5B)(\]|%5D)=[^&]*/g, "");

      // add back the one for this group"s material type
      query += `&material_types[]=${this.materialType}`;

      jQuery.ajax({
        dataType: "json",
        url: Portal.API_V1.SEARCH,
        data: query,
        success: response => this.updateState(response)
      });

      this.setState({ loading: true });
    }
  }

  updateState (groupData: any) {
    this.setState({ loading: false, group: groupData.results[0] });
  }

  renderLoading () {
    return (
      <div className="border_top">
        <p>Finding materials...</p>
      </div>
    );
  }

  renderResults () {
    const { group } = this.state;
    return (
      <div>
        <p className="border_top">
          <SPaginationInfo info={group.pagination} />
        </p>
        <SPagination info={group.pagination} onSelect={this.onPaginationSelect} />
        <SMaterialsList materials={group.materials} />
        <br />
        <SPagination info={group.pagination} onSelect={this.onPaginationSelect} />
      </div>
    );
  }

  render () {
    const { group } = this.state;
    switch (group.type) {
      case "investigations":
        this.materialType = "Investigation";
        this.pageParam = "investigation_page";
        break;
      case "activities":
        this.materialType = "Activity";
        this.pageParam = "activity_page";
        break;
      case "interactives":
        this.materialType = "Interactive";
        this.pageParam = "interactive_page";
        break;
      case "collections":
        this.materialType = "Collection";
        this.pageParam = "collection_page";
        break;
      default:
        throw new Error("unknown group type");
    }

    return (
      <div id={`${group.type}_bookmark`} className={`materials_container ${group.type}`} data-testid="materials-container">
        <div className="material_list_header" data-testid="material-list-header">{ group.header }</div>
        { this.state.loading ? this.renderLoading() : this.renderResults() }
      </div>
    );
  }
}
