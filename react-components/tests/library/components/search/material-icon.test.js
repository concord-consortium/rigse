/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SMaterialIcon from 'components/search/material-icon'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search material icon', () => {

  it("should render with default props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {}
    }
    const configuration = {};
    const materialIcon = Enzyme.shallow(<SMaterialIcon material={material} configuration={configuration} />);
    expect(materialIcon.html()).toBe(pack(`
      <div class="material_icon" style="border:0px">
        <a class="thumb_link">
          <img src="http://example.com/icon" width="100%"/>
        </a>
      </div>
    `));
  });

  it("should render with unstarred favorties props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {
        browse: {
          url: "http://example.com/browse"
        }
      }
    }
    const configuration = {
      enableFavorites: true,
      favoriteClassMap:   {
        true:  "legacy-favorite-active",
        false: "legacy-favorite"
      },
      favoriteOutlineClass: "legacy-favorite-outline",
      width: 100,
      height: 200
    };
    const materialIcon = Enzyme.shallow(<SMaterialIcon material={material} configuration={configuration} />);
    expect(materialIcon.html()).toBe(pack(`
      <div class="material_icon" style="border:0px;width:100px;height:200px">
        <a class="thumb_link" href="http://example.com/browse">
          <img src="http://example.com/icon" width="100%"/>
        </a>
        <div class="legacy-favorite">★</div>
        <div class="legacy-favorite legacy-favorite-outline" style="color:#CCCCCC">☆</div>
      </div>
    `));
  });

  it("should render with starred favorties props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {
        browse: {
          url: "http://example.com/browse"
        }
      },
      is_favorite: true
    }
    const configuration = {
      enableFavorites: true,
      favoriteClassMap:   {
        true:  "legacy-favorite-active",
        false: "legacy-favorite"
      },
      favoriteOutlineClass: "legacy-favorite-outline",
      width: 100,
      height: 200
    };
    const materialIcon = Enzyme.shallow(<SMaterialIcon material={material} configuration={configuration} />);
    expect(materialIcon.html()).toBe(pack(`
      <div class="material_icon" style="border:0px;width:100px;height:200px">
        <a class="thumb_link" href="http://example.com/browse">
          <img src="http://example.com/icon" width="100%"/>
        </a>
        <div class="legacy-favorite legacy-favorite-active">★</div>
      </div>
    `));
  });

})