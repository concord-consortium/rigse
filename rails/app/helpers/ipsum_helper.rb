module IpsumHelper
  def ipsum(len)
    text =<<-IPSOM_OVER
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque vel neque sit
    amet nisi convallis fermentum. Nulla sit amet velit. Nam suscipit. Nunc vel
    ipsum. Phasellus vestibulum commodo felis. Sed condimentum. Donec ultricies
    aliquam est. Nullam elit. Lorem ipsum dolor sit amet, consectetur adipiscing
    elit. Nam non ligula id orci malesuada venenatis. Nullam eget nulla. Nam
    mattis lectus sit amet libero. Proin gravida. Cras eleifend luctus mi. Nam id
    turpis. Duis nibh ipsum, adipiscing in, venenatis et, feugiat at, sapien.
    Vestibulum lacus risus, ullamcorper eu, ultricies sit amet, sagittis id, nunc.
    Morbi massa mi, fringilla eget, auctor nec, placerat quis, leo.

    Aliquam in lacus. Quisque consectetur suscipit turpis. Mauris quis sapien.
    Nulla aliquet justo non erat dapibus pulvinar. In hac habitasse platea
    dictumst. Praesent dapibus pharetra ipsum. Morbi eget ante eget mi sagittis
    mattis. Mauris blandit ultrices justo. Suspendisse potenti. Etiam id massa at
    odio aliquet auctor. Mauris erat massa, posuere id, ultrices non, imperdiet
    id, ipsum.

    In malesuada ligula ut magna. In et neque. Nulla a purus. Suspendisse potenti.
    Suspendisse tincidunt hendrerit lacus. Donec lectus urna, imperdiet eu,
    malesuada non, euismod sed, velit. Fusce auctor blandit elit. Maecenas lacus.
    Praesent porttitor. Nulla feugiat dapibus dui.

    Ut eget ante id quam consequat fringilla. Quisque a tellus id metus vehicula
    venenatis. Nullam aliquet eleifend lacus. Suspendisse turpis lectus,
    vestibulum ut, hendrerit ut, facilisis at, sem. Proin sed ligula et metus
    vehicula eleifend. Aliquam erat volutpat. Phasellus cursus sem nec dolor.
    Etiam laoreet. Vestibulum ante ipsum primis in faucibus orci luctus et
    ultrices posuere cubilia Curae; Suspendisse lacus diam, tempus sed, varius ut,
    hendrerit quis, dolor. Aenean et nibh sed nisi porta hendrerit. Integer
    vehicula. Sed purus nisi, tristique a, lacinia vehicula, tincidunt ac, dui.
    Quisque arcu lectus, molestie sit amet, euismod sit amet, tincidunt id, eros.
    Nulla sed ligula rhoncus orci blandit condimentum. Maecenas pretium velit at
    urna. Etiam tincidunt elit eu lacus.

    Quisque diam justo, tincidunt quis, vulputate ut, rhoncus sed, odio. In sit
    amet augue. Pellentesque ornare auctor lorem. Aenean convallis elit nec felis.
    Nam faucibus. Vivamus auctor lacus ac nibh malesuada faucibus. Praesent
    pretium tincidunt purus. Suspendisse potenti. Suspendisse quis nulla ac quam
    pretium tempor. Proin neque neque, scelerisque vel, tincidunt condimentum,
    volutpat ac, dui. Etiam metus. Suspendisse volutpat fringilla leo. Nunc arcu
    lacus, lobortis nec, porttitor vel, pharetra quis, lacus. Nunc ac dolor ut
    massa semper bibendum. Aenean id nisl. Curabitur rutrum rutrum mi.
    IPSOM_OVER
    if (defined?(len)) 
      return truncate(text,:length=>len)
    end
    return text
  end
  
end