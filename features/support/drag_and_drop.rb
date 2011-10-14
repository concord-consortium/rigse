# Simulate a scriptaculous drag event:
# TODO: only use while selenium busted in FF. see issue http://bit.ly/q9LHR4
def fake_drop(from,to)
  to = to.gsub(/#/,"")
  from = from.gsub(/#/,"")
  script = <<-EOF
    var drop = Droppables.drops.find( function (e) { if (e.element.id == '#{to.gsub(/#/,"")}') return true; });
    if (drop) {
      drop.onDrop($('#{from}'));
    }
  EOF
  page.execute_script(script)
end
