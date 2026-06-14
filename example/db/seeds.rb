# One user per role so you can sign in and watch the allowed values change.
[Comment, Post, Author, User].each(&:destroy_all)

member = User.create!(name: "Mia Member", role: "member")
editor = User.create!(name: "Eddie Editor", role: "editor")
admin  = User.create!(name: "Ada Admin", role: "admin")

author = Author.create!(name: "Quentin Commenter", role: "member")

welcome = admin.posts.create!(title: "Welcome", status: "published", tags: %w[ruby rails])
welcome.comments.create!(body: "Great first post!", status: "visible", author: author)

editor.posts.create!(title: "Draft idea", status: "draft", tags: %w[pundit])
member.posts.create!(title: "My first draft", status: "draft", tags: %w[ruby])

puts "Seeded #{User.count} users, #{Post.count} posts, #{Comment.count} comments."
