module.exports = {
	transform: {
		"\\.[jt]sx?$": "babel-jest"
	},
	
	moduleNameMapper: {
		"\\.(css|less)$": "identity-obj-proxy"
	},

	testEnvironment: "jsdom"
};
