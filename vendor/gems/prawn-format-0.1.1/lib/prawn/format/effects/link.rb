# encoding: utf-8

module Prawn
  module Format
    module Effects

      class Link
        def initialize(target, x)
          @target = target.sub(/^#/, "")
          @x = x
        end

        def finish(document, draw_state)
          x1 = draw_state[:real_x] + @x
          x2 = draw_state[:real_x] + draw_state[:dx]
          y  = draw_state[:real_y] + draw_state[:dy]

          rect = [x1, y + draw_state[:line].descent, x2, y + draw_state[:line].ascent]
          document.link_annotation(rect, :Dest => @target, :Border => [0,0,0])
        end

        def wrap(document, draw_state)
          finish(document, draw_state)
          @x = 0
        end
      end

    end
  end
end
