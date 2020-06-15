/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import TextPreview, { PREVIEW_LENGTH } from 'components/standards/text-preview'

Enzyme.configure({adapter: new Adapter()})

const text = "this is a long string of text"

describe('When I try to render text preview', () => {
  let textPreview;

  it('exports PREVIEW_LENGTH', () => {
    expect(PREVIEW_LENGTH).toBe(17);
    expect(text.length).toBeGreaterThan(PREVIEW_LENGTH);
  })

  describe('with preview=false', () => {
    beforeEach(() => {
      textPreview = Enzyme.mount(<TextPreview config={{
        text,
        preview: false
      }} />)
    })

    it("should not add an ellipsis", () => {
      expect(textPreview.html()).toBe(`<div style="cursor: default;">${text}</div>`);
    });
  });

  describe('with preview=true', () => {
    beforeEach(() => {
      textPreview = Enzyme.mount(<TextPreview config={{
        text,
        preview: true
      }} />)
    })

    it("should add an ellipsis", () => {
      expect(textPreview.html()).toBe(`<div style="cursor: default;">${text.substring(0, PREVIEW_LENGTH) + " ..."}</div>`);
    });
  });

})
