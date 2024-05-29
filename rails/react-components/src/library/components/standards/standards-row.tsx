import React from "react";
import TextPreview from "./text-preview";

export default class StandardsRow extends React.Component<any, any> {
  constructor (props: any) {
    super(props);
    this.state = {
      updating: false
    };
    this.handleButton = this.handleButton.bind(this);
  }

  handleButton (e: any) {
    const { statement, material, afterChange, skipModal } = this.props;
    let apiUrl: any = null;
    let add = false;

    const params = {
      identifier: statement.uri,
      material_type: material.material_type,
      material_id: material.material_id
    };

    if (!statement.is_applied) {
      apiUrl = "/api/v1/materials/add_materials_standard";
      add = true;
      if (!skipModal) {
        Portal.showModal("#asn_search_modal", "Processing...", true);
      }
    } else {
      apiUrl = "/api/v1/materials/remove_materials_standard";
    }

    this.setState({ updating: true }, () => {
      jQuery.ajax({
        type: "POST",
        url: apiUrl,
        data: params,
        dataType: "json",

        success: data => {
          statement.is_applied = !statement.is_applied;
          this.setState({ updating: false });

          if (afterChange) {
            afterChange();
          }
          if (window.loadAppliedStandards) {
            window.loadAppliedStandards();
          }
          if (add && !skipModal) {
            return Portal.hideModal();
          }
        },

        error: (jqXHR, textStatus, errorThrown) => {
          this.setState({ updating: false });
          return console.error("ERROR", jqXHR.responseText, jqXHR);
        }
      });
    });

    return e.preventDefault();
  }

  render () {
    let buttonText;
    const { updating } = this.state;
    const { statement } = this.props;

    if (!statement.is_applied) {
      buttonText = updating ? "Adding..." : "Add";
    } else {
      buttonText = updating ? "Removing..." : "Remove";
    }

    let leaf = "";
    if (statement.is_leaf) {
      leaf = "&#10004;";
    }

    let grades = "";
    if (statement.education_level != null) {
      grades = statement.education_level.join(", ");
    }

    return (
      <tr className="asn_results_tr">
        <td className="asn_results_td">{ statement.doc }</td>
        <td className="asn_results_td asn_results_td_fixed">
          <TextPreview config={{ text: statement.description, preview: true }} />
        </td>
        <td className="asn_results_td asn_results_td_fixed">
          <TextPreview config={{ text: statement.statement_label, preview: true }} />
        </td>
        <td className="asn_results_td">{ statement.statement_notation }</td>
        <td className="asn_results_td">
          <a href={statement.uri} target="_blank" dangerouslySetInnerHTML={{ __html: "&#128279;" }} rel="noreferrer" />
        </td>
        <td className="asn_results_td">{ grades }</td>
        <td className="asn_results_td">
          <div dangerouslySetInnerHTML={{ __html: leaf }} />
        </td>
        <td className="asn_results_td_right">
          <button onClick={this.handleButton}>{ buttonText }</button>
        </td>
      </tr>
    );
  }
}
