var obj_dao = require('../objects/database');

var Notifications = function(user_id_)
{
	this.user_id = user_id_;
	this.new_replies = [];
	this.new_followers = [];
	this.new_items = [];
	this.actual_count = 0;

	this.check_all = check_all.bind(this);
}

var check_all = function(callback)
{
	// Refresh the items list
	this.new_items = [];

	var dao = new obj_dao.DAO();

	// Check unseen comments
	dao.query("SELECT r.recipe_id, rc.owner_id, rc.date_added, rc.content, r.recipe_name FROM recipe_comment rc JOIN recipe r ON rc.recipe_id = r.recipe_id WHERE BINARY r.owner_id = '" + dao.safen(this.user_id) + "' AND rc.seen = 0 AND NOT BINARY rc.owner_id = '" + dao.safen(this.user_id) + "' ORDER BY rc.date_added", replies_output, this);

	function replies_output(success, result, fields, obj)
	{
		if (!success)
		{
			callback1(false);
			return;
		}

		obj.new_replies = [];
		for (var i in result)
		{
			var row = result[i];
			var content = row.content.substring(0, 100);
			if (row.content.length > content.length)
				content += " ...";
			obj.new_replies.push({type: 0, recipe_id: row.recipe_id, recipe_name: row.recipe_name, comment_owner: row.owner_id, content: content, date: new Date(row.date_added)});
		}

		dao.query("SELECT user_id_1, date_added FROM user_connections WHERE BINARY user_id_2 = '" + dao.safen(obj.user_id) + "' AND accepted = 0 AND seen = 0", followers_output, obj);
	}

	function followers_output(success, result, fields, obj)
	{
		if (!success)
		{
			callback1(false);
			return;
		}

		obj.new_followers = [];
		for (var i in result)
		{
			var row = result[i];
			obj.new_followers.push({type: 1, follower: row.user_id_1, date: new Date(row.date_added)});
		}

		dao.die();
		callback1(true);
	}


	var that = this;

	function callback1(success)
	{
		if (!success)
		{
			callback(false);
			return;
		}

		that.new_items = that.new_items.concat(that.new_replies);
		that.new_items = that.new_items.concat(that.new_followers);

		that.actual_count = that.new_items.length;
		
		function compare(a,b) 
		{
			if (a.date < b.date)
				return 1;
			if (a.date > b.date)
				return -1;
			return 0;
		}
		that.new_items.sort(compare);

		callback(true);
	}
}

Function.prototype.bind = function(obj)
{
	var method = this, 
	temp = function() 
	{ 
		return method.apply(obj, arguments); 
	}; 

return temp; 
}

exports.Notifications = Notifications;
exports.check_all = check_all;