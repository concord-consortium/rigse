import React from "react";
import css from "./style.scss";
import TeacherProjectViews from "./teacher-project-views";

const ROOT_SELECTION = "__ROOT__";
const SECTION_TYPE = "SECTION";

/*
* See `README.md` in this folder
* for the complete netsed structure of the Navigation props.
*/
export default class Navigation extends React.Component<any, any> {
  static defaultProps = {
    greeting: "Welcome,",
    name: "Guest",
    links: []
  };

  closeTimeout: any;
  constructor (props: any) {
    super(props);
    this.state = {
      opened: true,
      location: props.selected_section,
      openedSection: props.selected_section
    };
  }

  componentDidMount () {
    if (this.props.overlay) {
      this.closeTimeout = setTimeout(() => this.setState({ opened: false }), 3000);
    }
  }

  renderHead () {
    const { greeting, name } = this.props;
    const clickHeader = (e: any) => {
      this.setState((prevState: any) => ({ opened: !prevState.opened }));
      if (this.closeTimeout) {
        window.clearTimeout(this.closeTimeout);
      }
    };
    const classes = [css.head];
    classes.push(this.state.opened ? css.open : css.closed);
    return (
      <div className={classes.join(" ")} onClick={clickHeader} >
        <p>
          <span className={css.greeting}>{ greeting }</span>
          <br />
          <strong>{ name }</strong>
        </p>
      </div>
    );
  }

  getLinkClasses (linkDef: any) {
    const classes = (linkDef.classNames?.split()) || [];
    if (linkDef.small) {
      classes.push("small");
    }
    if (linkDef.divider) {
      classes.push("divider");
    }
    return classes;
  }

  renderLink (linkDef: any) {
    const { popOut, iconName, label, url, onClick, noIcon } = linkDef;
    const { location } = this.state;
    const target = popOut ? "_blank" : "_self";
    const icon = noIcon ? undefined : (popOut && iconName !== "icon-help" ? "icon-arrow-circle-right" : iconName);
    const classNames = this.getLinkClasses(linkDef);
    const selected = linkDef.id === location;
    if (selected) {
      classNames.push("selected");
    }
    const linkStyles = classNames
      .map((name: any) => css[name] || name)
      .join(" ")
      .replace(/^\s+|\s+$/g, "");
    const clickHandler = (e: any) => {
      // don't trigger the event in parents.
      e.stopPropagation();
      if (onClick) {
        onClick(e);
      }
      return true;
    };
    return (
      <li className={linkStyles} onClick={clickHandler} key={linkDef.id}>
        <a href={url} target={target}>
          { icon ? <div className={css.icon}><i className={icon} /></div> : null }
          { label }
        </a>
      </li>
    );
  }

  isInSection (openSection: any, thisSection: any) {
    const _sections = openSection.split("/");
    const _thisSections = thisSection.split("/");
    let found = true;
    let index = 0;
    while (index < _thisSections.length && found) {
      found = _thisSections[index] === _sections[index];
      index++;
    }
    if (found) {
      return thisSection;
    }
    return false;
  }

  renderSection (section: any) {
    const { openedSection, location } = this.state;
    const inSection = this.isInSection(openedSection, section.id);
    const inLocation = location.match(section.id);
    const inRoot = section.id === ROOT_SELECTION;
    const children = section.children.map((i: any) => this.renderItem(i));
    const classNames = [css.section];
    if (inSection && (!inRoot)) { classNames.push(css.open); }
    if (inLocation && (!inRoot)) { classNames.push("in-selection"); }

    const styles = classNames
      .map((name) => css[name] || name)
      .join(" ")
      .replace(/^\s+|\s+$/g, "");

    const displayName = section.id === ROOT_SELECTION ? "" : section.label;
    const parentPathTree = section.id.split("/");

    parentPathTree.pop();
    // const parentId = parentPathTree.join('/') || ROOT_SELECTION

    const clickHandler = (e: any) => {
      e.stopPropagation();
      if (inSection && !inRoot) {
        if (section.id === inSection) {
          const parentId = inSection.split("/").slice(0, -1).join("/");
          this.setState({ openedSection: parentId });
        } else {
          this.setState({ openedSection: inSection });
        }
      } else {
        this.setState({ openedSection: section.id });
      }
      return true;
    };
    return (
      <li className={styles} onClick={clickHandler} key={section.id}>
        { displayName }
        <span className={inSection ? css.open : css.closed} />
        <ul>
          { children }
        </ul>
        { section.divider ? <hr /> : "" }
      </li>
    );
  }

  renderItem (item: any) {
    if (item.type === SECTION_TYPE) {
      return this.renderSection(item);
    } else {
      return this.renderLink(item);
    }
  }

  sortLinks (links: any) {
    links.forEach((item: any) => {
      if (item.children) {
        item.children = this.sortLinks(item.children);
      }
    });

    return links.sort((a: any, b: any) => {
      if (a.sort < b.sort) {
        return -1;
      }
      if (a.sort > b.sort) {
        return 1;
      }
      return 0;
    });
  }

  render () {
    const items = this.sortLinks(this.props.links);
    const rendered = items.map((item: any) => this.renderItem(item));
    const head = this.renderHead();
    const classNames = [css.leftNavigation];

    if (this.props.overlay) {
      classNames.push(css.overlay);
    }
    if (!this.state.opened) {
      classNames.push(css.closed);
    }

    return (
      <div className={classNames.join(" ")}>
        { head }
        <ul>
          { rendered }
        </ul>
        { Portal.currentUser.isTeacher && <TeacherProjectViews /> }
      </div>
    );
  }
}
