# One user per role so you can sign in and watch the allowed values change.
[ Comment, Post, Author, User ].each(&:destroy_all)

member = User.create!(name: "Mia Member", role: "member")
editor = User.create!(name: "Eddie Editor", role: "editor")
admin  = User.create!(name: "Ada Admin", role: "admin")

author = Author.create!(name: "Quentin Commenter", role: "member")

welcome = admin.posts.create!(title: "Welcome", status: "published", tags: %w[ruby rails pundit])
welcome.comments.create!(body: "Great first post!", status: "visible", author: author)

admin.posts.create!(title: "Hardening guide", status: "published", tags: %w[ruby security performance])
editor.posts.create!(title: "Draft idea", status: "draft", tags: %w[rails pundit])
member.posts.create!(title: "My first draft", status: "draft", tags: %w[ruby rails])

puts "Seeded #{User.count} users, #{Post.count} posts, #{Comment.count} comments."
