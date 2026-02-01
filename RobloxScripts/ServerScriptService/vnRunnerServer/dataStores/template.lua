export type playerData = {
	settings: {
		sound: {
			bgm: number,
			sfx: number,
		},
		visuals: {
			scrollSpeed: number,
		},
	},
	saves: {
		[number]: {
			chapterIndex: number,
			sceneIndex: number,
			timestamp: number,
			storyVariables: {[string]: number | string | boolean},
			background: string,
		}
	},
	storyVariables: {[string]: string | boolean | number},
	chaptersUnlocked: {number},
}

local template: playerData = {
	settings = {
		sound = {
			bgm = 1,
			sfx = 1,
		},
		visuals = {
			scrollSpeed = 1,
		},
	},
	saves = {},
	storyVariables = {},
	chaptersUnlocked = {1},
}

return template