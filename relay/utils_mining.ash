/**********************************************
                 Developed by:
      the coding arm of ProfessorJellybean.
             (#2410942), (#2413598)

 Please don't KMail me unless there are issues.
     I'm glad you're using this but I have
             enough mail already :P

	====================================

    This script should not be invoked with
    gCLI. It is meant to be a utilities suite
    for other scripts.

		Up-to-date as of January 8, 2016.

**********************************************/

// Documentation Notes
/***
http://kol.coldfront.net/thekolwiki/index.php/Mining

Intent: Mining utilities for use in other scripts.
Domain: Executable ASH Scripts in the Mafia utility
  for the Kingdom of Loathing
  (http://www.kingdomofloathing.com/)

Full documentation:
https://github.com/AllenTuring/KoLMinerUtils/wiki/Documentation

***/

/** MINE INFORMATION **/
// These functions are concerned with the passive mine state.
// And do not require the mine to be loaded.
// They do not perform any actions.

int[string] utils_mining_mineCodesByName;
utils_mining_mineNamesByMineCode["The Velvet / Gold Mine (Mining)"] = 6;

// Returns the mineCode of a mine by name, consistent with getMineName
// Not case-sensitive.
int utils_mining_getMineCodeExact(string mine) {
	if (utils_mining_mineCodesByName contains mine) {
		return utils_mining_mineCodesByName[mine];
	}
	return -1;
}

// Returns the mineCode of a mine by name or partial match thereof.
int utils_mining_getMineCode(string mine) {
	int exact = utils_mining_getMineCodeExact(mine);
	if (exact != -1) {
		return exact;
	}

	mine = to_lower_case(mine);
	matcher match = create_matcher(mine, "");
	for name, code in utils_mining_mineCodesByName {
		match.reset(name);
		if match.find(); {
			return code;
		}
	}
	return -1;
}

// Returns the name of the mine based off of mineCode.
string utils_mining_getMineName(int mineCode) {
	for name, code in utils_mining_mineCodesByName {
		if (mineCode == code) {
			return name;
		}
	}
	return "Mine code unknown.";
}

/** PLAYER INFORMATION **/
// These functions are concerned with the playerstate
// And do not require the mine to be loaded.
// They do not perform any actions.

// Checks whether or not the player is equipped to mine generic mines.
// Expression: (Mining Gear) v (Dwarvish War Uniform) v (WOTSF ^ Earthen Fist)
boolean utils_mining_wearingMiningGear() {
	return is_wearing_outfit("Mining Gear")
	|| is_wearing_outfit("Dwarvish War Uniform")
	|| (my_path() == "Way of the Surprising Fist" && have_effect($effect[Earthen Fist]) > 0);
}

// Checks whether or not the player is fit to mine.
// Does not check for access to a specific mine.
// Does not check for mining gear (some mines have special gear.)
// Return codes are listed on the project wiki.
int utils_mining_canAdventure() {
	//Check if the player is not drunk.
	if(my_inebriety() > inebriety_limit()) {
		return 1;
	}

	//Checks for remaining adventures
	if (my_adventures() == 0) {
		return 2;
	}
	
	//Checks that the player is not beaten up
	if (have_effect($effect[Beaten Up]) != 0) {
		return 3;
	}

	return 0;
}

int utils_mining_canMine(int MineCode) {
	//Check canAdventure();
	int advcheck = utils_mining_canAdventure();
	if(advcheck != 0) {
		return advcheck;
	}
	
	//Checks that the player is not beaten up
	if (have_effect($effect[Beaten Up]) != 0) {
		return 3;
	}

	return 0;
}

/** MINE PARSING **/
// These functions are concerned with the parsing of
// the mine's data.

/** ACTIONS */
// These functions do stuff. Use with caution.

// Your password hash, for POST requests.
string utils_mining_pwhash = "&pwd=" + my_hash();

// Mines at a specified spot in a given mine.
buffer utils_mining_mineAtSpot(int mineCode, int col, int row) {
	string url = "mining.php?mine=" + mineCode;
	url = url + "&which=" + (col + (8 * row)) + utils_mining_pwhash;
	return visit_url(url, true);
}

// Resets a given mine.
buffer utils_mining_mineAtSpot(int mineCode) {
	string url = "mining.php?reset=1&mine=" + mineCode + utils_mining_pwhash;
	return visit_url(url, true);
}