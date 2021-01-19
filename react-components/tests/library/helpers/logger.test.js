/* globals describe it expect */

import { mockJquery } from "./mock-jquery"
import { getDefaultData, logEvent, postLogEvent } from "../../../src/library/helpers/logger"

describe('Logger', () => {

  const ajax = jest.fn()

  mockJquery({
    ajax,
    extend: (deep, ...args) => Object.assign.apply(this, args)
  })

  it("has an application name", () => {
    expect(getDefaultData().application).toBe("rigse-log")
  })

  it("handles anonymous users", () => {
    delete window.Portal
    expect(getDefaultData().username).toBe("anonymous")
  })

  it("handles logged in users", () => {
    window.Portal = {
      currentUser: {
        isAnonymous: false,
        userId: 1
      }
    }
    expect(getDefaultData().username).toBe("1@portal-test.concord.org")
  })

  it("posts to the log manager directly", () => {
    const data = postLogEvent({event: "test with object", foo: "bar"})
    expect(ajax).toHaveBeenCalled()
    expect(data.event).toEqual("test with object")
    expect(data.foo).toEqual("bar")
    expect(data.time).toBeDefined()
  })

  it("posts to the log manager via logEvent", () => {
    const data = logEvent("test with string")
    expect(ajax).toHaveBeenCalled()
    expect(data.event).toEqual("test with string")
    expect(data.time).toBeDefined()
  })

})
