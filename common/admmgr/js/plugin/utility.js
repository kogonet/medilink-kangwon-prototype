jQuery.fn.keyCode = function () {

	return this.get(0).which || this.get(0).keyCode;

};

jQuery.fn.rowLength = function () {

	return this.get(0).rows.length;

};

jQuery.fn.getParent = function (tag_name) {

	if (!tag_name) {

		return this.parent();

	} else {

		var parent_target = this;
		while (true) {

			var parent_tag_name = parent_target.get(0).nodeName.toLowerCase();
			if (parent_tag_name == tag_name) {

				return parent_target;

			} else if (parent_tag_name == "body" || parent_tag_name == "html") {

				return null;

			}

			parent_target = parent_target.parent();

		}

	}

};