/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StandardsRow from 'components/standards/standards-row'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

const text = "this is a long string of text"

const material = {
  material_id: 1,
  material_type: "test-material-type",
};

const defaultStatement = {
  uri: "https://example.com/",
  is_applied: false,
  is_leaf: false,
  education_level: [],
  doc: "doc",
  description: "description",
  statement_label: "statement_label",
  statement_notation: "statement_notation",
}

describe('When I try to render a standards row', () => {
  let standardsRow;

  describe("when using a default statement", () => {
    beforeEach(() => {
      standardsRow = Enzyme.mount(<table><tbody><StandardsRow statement={defaultStatement} material={material} /></tbody></table>)
    });

    it("renders correctly", () => {
      expect(standardsRow.html()).toBe(pack(`
        <table><tbody>
        <tr class="asn_results_tr">
          <td class="asn_results_td">doc</td>
          <td class="asn_results_td asn_results_td_fixed">
            <div style="cursor: default;">description</div>
          </td>
          <td class="asn_results_td asn_results_td_fixed">
            <div style="cursor: default;">statement_label</div>
          </td>
          <td class="asn_results_td">statement_notation</td>
          <td class="asn_results_td"><a href="https://example.com/" target="_blank">🔗</a></td>
          <td class="asn_results_td"></td>
          <td class="asn_results_td"><div></div></td>
          <td class="asn_results_td_right"><button>Add</button></td>
        </tr>
        </tbody></table>`));
    })
  });

  describe("when using a default statement with is_applied set to true", () => {
    beforeEach(() => {
      const statement = Object.assign({}, defaultStatement, {is_applied: true});
      standardsRow = Enzyme.mount(<table><tbody><StandardsRow statement={statement} material={material} /></tbody></table>)
    });

    it("renders is_applied correctly", () => {
      expect(standardsRow.html()).toBe(pack(`
        <table><tbody>
        <tr class="asn_results_tr">
          <td class="asn_results_td">doc</td>
          <td class="asn_results_td asn_results_td_fixed">
            <div style="cursor: default;">description</div>
          </td>
          <td class="asn_results_td asn_results_td_fixed">
            <div style="cursor: default;">statement_label</div>
          </td>
          <td class="asn_results_td">statement_notation</td>
          <td class="asn_results_td"><a href="https://example.com/" target="_blank">🔗</a></td>
          <td class="asn_results_td"></td>
          <td class="asn_results_td"><div></div></td>
          <td class="asn_results_td_right"><button>Remove</button></td>
        </tr>
        </tbody></table>`));
    })
  });

  describe("when using a default statement with is_leaf set to true", () => {
    beforeEach(() => {
      const statement = Object.assign({}, defaultStatement, {is_leaf: true});
      standardsRow = Enzyme.mount(<table><tbody><StandardsRow statement={statement} material={material} /></tbody></table>)
    });

    it("renders is_leaf correctly", () => {
      expect(standardsRow.html()).toBe(pack(`
        <table><tbody>
        <tr class="asn_results_tr">
          <td class="asn_results_td">doc</td>
          <td class="asn_results_td asn_results_td_fixed">
            <div style="cursor: default;">description</div>
          </td>
          <td class="asn_results_td asn_results_td_fixed">
            <div style="cursor: default;">statement_label</div>
          </td>
          <td class="asn_results_td">statement_notation</td>
          <td class="asn_results_td"><a href="https://example.com/" target="_blank">🔗</a></td>
          <td class="asn_results_td"></td>
          <td class="asn_results_td"><div>✔</div></td>
          <td class="asn_results_td_right"><button>Add</button></td>
        </tr>
        </tbody></table>`));
    })
  });

  describe("when using a default statement with education_level set", () => {
    beforeEach(() => {
      const statement = Object.assign({}, defaultStatement, {education_level: [1, 2, 3]});
      standardsRow = Enzyme.mount(<table><tbody><StandardsRow statement={statement} material={material} /></tbody></table>)
    });

    it("renders education_level correctly", () => {
      expect(standardsRow.html()).toBe(pack(`
        <table><tbody>
        <tr class="asn_results_tr">
          <td class="asn_results_td">doc</td>
          <td class="asn_results_td asn_results_td_fixed">
            <div style="cursor: default;">description</div>
          </td>
          <td class="asn_results_td asn_results_td_fixed">
            <div style="cursor: default;">statement_label</div>
          </td>
          <td class="asn_results_td">statement_notation</td>
          <td class="asn_results_td"><a href="https://example.com/" target="_blank">🔗</a></td>
          <td class="asn_results_td">1, 2, 3</td>
          <td class="asn_results_td"><div></div></td>
          <td class="asn_results_td_right"><button>Add</button></td>
        </tr>
        </tbody></table>`));
    })
  });
})
