def anonymize_users
  fake_first_names = %w[Bob Joe John Noah Jen Stephen Anand Tanzeel Jimmie Scott Frieda Barbara Forest Hannah Ada Linden Albert Stuart David Stephen Linda
Lucy Dot Amy Alice Beatrice Charles Cindy Harper Row Harry Hermione Bilbo Frodo Gandalf Merlin Dan]
  fake_last_names =%w[ Vega Morrison Schmidt Paessel Fields Wiesel Rossoff Balaji Kazi Shroff Kofi VanHoot Mann Benjamin Hsu Tang Kirchoff Kennedy Lincoln Edwards Clinton Potter Baggins Gamgee Scott Unger Kells Sloane]
   User.find_each do |user|
     user.first_name = fake_first_names[rand(fake_first_names.length)]
     user.last_name = fake_last_names[rand(fake_last_names.length)]
     login = User.suggest_login(user.first_name, user.last_name)
     user.login=login
     user.email="#{login}@google.com"
     user.password = 'password'
     user.password_confirmation = 'password'
     user.updating_password = true
     user.save
   end
end

 
