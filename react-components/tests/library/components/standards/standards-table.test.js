/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StandardsTable, { PAGE_SIZE } from 'components/standards/standards-table'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

const text = "this is a long string of text"

const material = {
  material_id: 1,
  material_type: "test-material-type",
};

const makeStatements = (count) => {
  const statements = [];
  for (let i = 0; i < count; i++) {
    statements.push({
        uri: `https://example.com/${i}`,
        is_applied: i === 1,
        is_leaf: i === 2,
        education_level: i === 3 ? [1, 2, 3] : [],
        doc: `doc ${i}`,
        description: `description ${i}`,
        statement_label: `statement_label ${i}`,
        statement_notation: `statement_notation ${i}`,
    })
  }
  return statements;
};

describe('When I try to render a standards table', () => {
  let standardsTable;

  it('exports PAGE_SIZE', () => {
    expect(PAGE_SIZE).toBe(10);
  })

  describe("without pagination", () => {
    beforeEach(() => {
      const statements = makeStatements(2);
      standardsTable = Enzyme.mount(<StandardsTable statements={statements} material={material} start={0} />)
    });

    it("renders without pagination correctly", () => {
      expect(standardsTable.html()).toBe(pack(`
        <table class="asn_results_table">
          <tbody>
            <tr>
              <th class="asn_results_th">Type</th>
              <th class="asn_results_th">Description</th>
              <th class="asn_results_th">Label</th>
              <th class="asn_results_th">Notation</th>
              <th class="asn_results_th">URI</th>
              <th class="asn_results_th">Grades</th>
              <th class="asn_results_th">Leaf</th>
              <th class="asn_results_th_right">Action</th>
            </tr>
            <tr class="asn_results_tr">
              <td class="asn_results_td">doc 0</td>
              <td class="asn_results_td asn_results_td_fixed">
                <div style="cursor: default;">description 0</div>
              </td>
              <td class="asn_results_td asn_results_td_fixed">
                <div style="cursor: default;">statement_label 0</div>
              </td>
              <td class="asn_results_td">statement_notation 0</td>
              <td class="asn_results_td"><a href="https://example.com/0" target="_blank">🔗</a></td>
              <td class="asn_results_td"></td>
              <td class="asn_results_td"><div></div></td>
              <td class="asn_results_td_right"><button>Add</button></td>
            </tr>
            <tr class="asn_results_tr">
              <td class="asn_results_td">doc 1</td>
              <td class="asn_results_td asn_results_td_fixed">
                <div style="cursor: default;">description 1</div>
              </td>
              <td class="asn_results_td asn_results_td_fixed">
                <div style="cursor: default;">statement_label 1</div>
              </td>
              <td class="asn_results_td">statement_notation 1</td>
              <td class="asn_results_td"><a href="https://example.com/1" target="_blank">🔗</a></td>
              <td class="asn_results_td"></td>
              <td class="asn_results_td"><div></div></td>
              <td class="asn_results_td_right"><button>Remove</button></td>
            </tr>
          </tbody>
        </table>`));
    })
  })

})
