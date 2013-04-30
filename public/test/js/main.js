require.config({
	paths: {
		"underscore": "libs/underscore",
		"backbone": "libs/backbone",
		"templates": "../templates"
	},
	shim: {
		underscore: {
			exports: '_'
		},
		backbone: {
			deps: ["underscore", "jquery"],
			exports: "Backbone"
		}
	}
});

require([
	"giftique"
], function(Giftique){
	Giftique.initialize();
});