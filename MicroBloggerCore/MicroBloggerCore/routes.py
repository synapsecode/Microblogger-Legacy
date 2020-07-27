from flask import render_template, url_for, flash, redirect, request, jsonify
from MicroBloggerCore import app, db
from MicroBloggerCore.models import (User, MicroBlogPost, BlogPost, TimelinePost, ShareablePost, PollPost, ReshareWithComment, SimpleReshare, Comment)
from post_templates import microblog, blog, timeline, poll, shareable, reshareWithComment, simpleReshare, userTemplate

#TODO: Unify functions and make it efficient

@app.route("/")
def homepage():
	return "Welcome to the microblogger API"

@app.route("/login", methods=['POST'])
def loginpage():
	data = request.get_json()
	username = data['username']
	password = data['password']
	user_record = User.query.filter_by(username=username, password=password).first()
	if(user_record):
		return jsonify({
			'code': 'S1',
			'user': userTemplate(user_record)
		})
	else:
		return jsonify({
			'code': 'E1',
			'message': 'Incorrect username or password'
		})

@app.route("/register", methods=['POST'])
def registerpage():
	data = request.get_json()
	username = data['username']
	password = data['password']
	email = data['email']
	new_user = User(username=username, email=email, password=password)
	db.session.add(new_user)
	db.session.commit()
	user_record = User.query.filter_by(username=username, password=password).first()
	print(user_record)
	return jsonify({
		'code': 'S1',
		'user': userTemplate(user_record)
	})

@app.route("/all_users")
def allusers():
	users = User.query.all()
	return jsonify(
		{
			'code': 'S1',
			'users': [userTemplate(u) for u in users]
		}
	)

@app.route("/profile/<username>")
def getprofile(username):
	user_record = User.query.filter_by(username=username).first()
	if(user_record):
		return jsonify({
			'code': 'S1',
			'user': userTemplate(user_record)
		})
	else:
		return jsonify({
			'code': 'E2',
			'message': 'Profile does not exist!'
		})

@app.route('/feed', methods=['POST'])
def feed():
	#TODO: Make it more efficient!! URGENT!!!!
	data = request.get_json()
	username = data['username']
	print(f"username: {username}")
	user = User.query.filter_by(username=username).first()
	if(user):
		feed = []
		following = user.my_following
		for u in [user.username, *following]:
			user = User.query.filter_by(username=u).first()
			[feed.append(microblog(user, x)) for x in MicroBlogPost.query.filter_by(author_id=user.id).all()]
			[feed.append(blog(user, x)) for x in BlogPost.query.filter_by(author_id=user.id).all()]
			[feed.append(shareable(user, x)) for x in ShareablePost.query.filter_by(author_id=user.id).all()]
			[feed.append(poll(user, x)) for x in PollPost.query.filter_by(author_id=user.id).all()]
			[feed.append(timeline(user, x)) for x in TimelinePost.query.filter_by(author_id=user.id).all()]
			[feed.append(reshareWithComment(user, x)) for x in ReshareWithComment.query.filter_by(author_id=user.id).all()]
			[feed.append(simpleReshare(user, x)) for x in SimpleReshare.query.filter_by(author_id=user.id).all()]
		
		return jsonify({
			'code': 'S1',
			'feedlength': len(feed),
			'feed': feed
		})
	else:
		return jsonify({
			'code': 'E1',
			'message': 'Invalid user submission'
		})

#----------------------------------------------POST COMPOSER-----------------------------------------------
@app.route('/createmicroblog', methods=['POST'])
def create_microblog():
	data = request.get_json()
	username = data['username']
	content = data['content']
	category = data['category']
	user = User.query.filter_by(username=username).first()
	mxb = MicroBlogPost(author=user, category=category, content=content)
	db.session.add(mxb)
	db.session.commit()
	return jsonify({
		'microblog': microblog(user, mxb)
	})

@app.route('/createblog', methods=['POST'])
def create_blog():
	data = request.get_json()
	username = data['username']
	content = data['content']
	blog_name = data['blog_name']

	user = User.query.filter_by(username=username).first()
	xb = BlogPost(author=user, blog_name=blog_name, content=content, background="https://cdn.vox-cdn.com/thumbor/eHhAQHDvAi3sjMeylWgzqnqJP2w=/0x0:1800x1200/1200x0/filters:focal(0x0:1800x1200):no_upscale()/cdn.vox-cdn.com/uploads/chorus_asset/file/13272825/The_Verge_Hysteresis_Wallpaper_Small.0.jpg")

	db.session.add(xb)
	db.session.commit()
	return jsonify({
		'blog': blog(user, xb)
	})
#----------------------------------------------POST COMPOSER-----------------------------------------------

#-------------------------------------------------POSTACTIONS-----------------------------------------------
@app.route('/likepost', methods=['POST'])
def likemicrobloggerpost():
	data = request.get_json()
	username = data['username']
	post_type = data['post_type']
	post_id = data['post_id']
	user = User.query.filter_by(username=username).first()
	post = getPost(post_type, post_id)
	post.like(user)
	return jsonify({
		'message':'Liked Post' 
	})

@app.route('/unlikepost', methods=['POST'])
def unlikemicrobloggerpost():
	data = request.get_json()
	username = data['username']
	post_type = data['post_type']
	post_id = data['post_id']
	user = User.query.filter_by(username=username).first()
	post = getPost(post_type, post_id)
	post.unlike(user)
	return jsonify({
		'message':'Unliked Post' 
	})

@app.route('/bookmarkpost', methods=['POST'])
def bookmarkpost():
	data = request.get_json()
	username = data['username']
	post_type = data['post_type']
	post_id = data['post_id']
	user = User.query.filter_by(username=username).first()
	post = getPost(post_type, post_id)
	user.add_bookmark(post)
	return jsonify({
		'message':'Bookmarked Post' 
	})

@app.route('/unbookmarkpost', methods=['POST'])
def unbookmarkpost():
	data = request.get_json()
	username = data['username']
	post_type = data['post_type']
	post_id = data['post_id']
	user = User.query.filter_by(username=username).first()
	post = getPost(post_type, post_id)
	user.remove_bookmark(post)
	return jsonify({
		'message':'UnBookmarked Post' 
	})

@app.route('/reshare', methods=['POST'])
def resharepost():
	data = request.get_json()
	username = data['username']
	host_type = data['host_type']
	host_id = data['host_id']
	content = data['content']
	category = data['category']
	reshare_type = data['reshare_type']
	
	post = getPost(host_type, host_id)
	user = User.query.filter_by(username=username).first()

	if(reshare_type == 'ResharedWithComment'):
		rwc = ReshareWithComment(author=user, host=post, content=content, category=category)
		db.session.add(rwc)
		post.reshare(user=user, post=rwc)
	else:
		sr = SimpleReshare(author=user, host=post)
		db.session.add(sr1)
		post.reshare(user=user, post=sr1)
	return jsonify({
		'message':'Reshared Post' 
	})

@app.route('/unreshare', methods=['POST'])
def unresharepost():
	data = request.get_json()
	username = data['username']
	host_type = data['host_type']
	host_id = data['host_id']
	reshare_type = data['reshare_type'] 

	if(reshare_type == 'ResharedWithComment'):
		rwc = ReshareWithComment.query.filter_by(author=user, host_id=host_id).first()
		post.unreshare(user=user, post=rwc)
	else:
		sr = SimpleReshare.query.filter_by(author=user, host_id=host_id).first()
		post.unreshare(user=user, post=sr1)
	
	return jsonify({
		'message':'Unreshared Post' 
	})

@app.route('/comment', methods=['POST'])
def addcomment():
	data = request.get_json()
	username = data['username']
	post_type = data['post_type']
	post_id = data['post_id']
	content = data['content']
	category = data['category']

	user = User.query.filter_by(username=username).first()
	post = None
	c=None
	if(post_type == 'microblog'):
		post = MicroBlogPost.query.filter_by(post_id=post_id).first()
		c = Comment(author=user, content=content, category=category, microblog_parent=post)
	elif(post_type == 'blog'):
		post = BlogPost.query.filter_by(post_id=post_id).first()
		c = Comment(author=user, content=content, category=category, blog_parent=post)
	elif(post_type == 'timeline'):
		post = TimelinePost.query.filter_by(post_id=post_id).first()
		c = Comment(author=user, content=content, category=category, timeline_parent=post)
	elif(post_type == 'ResharedWithComment'):
		post = ReshareWithComment.query.filter_by(post_id=post_id).first()
		c = Comment(author=user, content=content, category=category, rwc_parent=post)
	
	db.session.add(c1)
	db.session.commit()

@app.route('/deletepost', methods=['POST'])
def deletepost():
	data = request.get_json()
	username = data['username']
	post_type = data['post_type']
	post_id = data['post_id']

	user = User.query.filter_by(username=username).first()
	post = getPost(post_type, post_id)

	if(post.author_id == user.id):
		db.session.delete(post)
		db.session.commit()
	else:
		return jsonify({
			'message':'Cannot delete post as you do not have the rights to do so' 
		})

	return jsonify({
		'message':'Deleted Post!' 
	})
#-------------------------------------------------POSTACTIONS-----------------------------------------------


def getPost(post_type, post_id):
	post = None
	if(post_type == 'microblog'):
		post = MicroBlogPost.query.filter_by(post_id=post_id).first()
	elif(post_type == 'blog'):
		post = BlogPost.query.filter_by(post_id=post_id).first()
	elif(post_type == 'shareable'):
		post = ShareablePost.query.filter_by(post_id=post_id).first()
	elif(post_type == 'poll'):
		post = PollPost.query.filter_by(post_id=post_id).first()
	elif(post_type == 'timeline'):
		post = TimelinePost.query.filter_by(post_id=post_id).first()
	elif(post_type == 'ResharedWithComment'):
		post = ReshareWithComment.query.filter_by(post_id=post_id).first()
	elif(post_type == 'comment'):
		post = Comment.query.filter_by(post_type=post_id).first()
	return post

"""
Add getters for my posst!
'my_microblogs' : [microblog(x) for x in user_record.my_microblogs],
'my_blogs' : str(user_record.my_blogs),
'my_timelines' : str(user_record.my_timelines),
'my_shareables' : str(user_record.my_shareables),
'my_reshareWithComments' : str(user_record.my_reshareWithComments),
'my_simpleReshares' : str(user_record.my_simpleReshares),
'my_polls' : str(user_record.my_polls),
'liked_posts': str(user_record.liked_posts), get when post is loaded to indicate sign

'bookmarked_posts': [x.post_id for x in user_record.bookmarked_posts]
'reshared_posts': str(user_record.reshared_posts), get when post is loaded to indicate sign
"""