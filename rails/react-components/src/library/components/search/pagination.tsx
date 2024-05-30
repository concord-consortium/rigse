import React, { createRef } from "react";

export default class SPagination extends React.Component<any, any> {
  divRef = createRef<HTMLDivElement>();

  componentDidMount () {
    if (this.props.info.total_pages < 2) {
      // don't display pagination if there's only 1 page
      return;
    }
    if (!this.divRef.current) {
      return;
    }

    const node = jQuery(this.divRef.current);
    // .paging is defined in jQuery plugin
    (node as any).paging(this.props.info.total_items, {
      format: "<  . (qq -) nnncnnn (- pp) >",
      perpage: this.props.info.per_page,
      lapping: 0,
      page: this.props.info.current_page,
      onSelect: this.props.onSelect,
      onFormat (type: any) {
        switch (type) {
          case "block":
            if (!this.active) {
              return `<span class='disabled'>${this.value}</span>`;
            } else if (this.value !== this.page) {
              return `<em><a href='#' class='page'>${this.value}</a></em>`;
            }
            return `<span class='current page'>${this.value}</span>`;

          case "next":
            if (this.active) {
              return "<a href='#' class='next'>Next →</a>";
            }
            return '<span class="disabled">Next →</span>';

          case "prev":
            if (this.active) {
              return "<a href='#' class='prev'>← Previous</a>";
            }
            return '<span class="disabled">← Previous</span>';

          case "first":
            if (this.active) {
              return "<a href='#' class='first'>|&lt;</a>";
            }
            return '<span class="disabled">|&lt;</span>';

          case "last":
            if (this.active) {
              return "<a href='#' class='last'>&gt;|</a>";
            }
            return '<span class="disabled">&gt;|</span>';

          case "leap":
            if (this.active) { return "   "; } else { return ""; }
          case "fill":
            if (this.active) { return "..."; } else { return ""; }
          default:
            return "";
        }
      }
    });
  }

  shouldComponentUpdate () {
    return false;
  }

  render () {
    return <div ref={this.divRef} className="pagination" />;
  }
}
