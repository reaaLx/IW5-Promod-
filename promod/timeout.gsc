#include maps\mp\gametypes\_hud_util;
main()
{
    game["promod_in_timeout"] = 1;
    thread promod\readyup::disableBombsites();
    thread promod\readyup::main();
    thread disableBombBag();
    level.timeout_over = false;
    level.timeout_time_left = 300;
    game["promod_timeout_called"] = false;
    thread timeoutLoop();
}
disableBombBag()
{
    if (level.gametype == "sd")
    {
        trigger = getEnt("sd_bomb_pickup_trig", "targetname");
        visuals = getEnt("sd_bomb", "targetname");
        if (isDefined(trigger))
            trigger delete ();
        if (isDefined(visuals))
            visuals delete ();
        if (isDefined(level.sdBomb))
            level.sdBomb maps\mp\gametypes\_gameobjects::setVisibleTeam("none");
    }
}
timeoutLoop()
{
    if (!isDefined(game["LAN_MODE"]) || !game["LAN_MODE"])
        thread timeoutLeft();
    if (!isDefined(level.ready_up_over))
        level.ready_up_over = false;
    while (!level.timeout_over)
    {
        wait 0.25;
        if (level.timeout_time_left <= 0 || level.ready_up_over)
        {
            level.timeout_over = true;
            level.ready_up_over = 1;
        }
    }
}
timeoutLeft()
{
    while (!level.timeout_over)
    {
        wait 0.25;
        level.timeout_time_left -= 0.25;
    }
}
timeoutCall()
{
    if ((isDefined(level.inReadyUpTimer) && level.inReadyUpTimer || isDefined(level.ready_up_over) && !level.ready_up_over || (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] != "match" && game["PROMOD_MATCH_MODE"] != "pub")) || (level.gametype != "sd" && level.gametype != "sab") || (self.pers["team"] != "axis" && self.pers["team"] != "allies"))
    {
        self iprintln("^3Timeout is not available right now");
        return;
    }
    if (isDefined(game["PROMOD_MATCH_MODE"]) && game["PROMOD_MATCH_MODE"] == "match" && (!isDefined(level.strat_over) || level.strat_over) && ((game["roundsPlayed"] + 1) % level.roundSwitch == 0))
    {
        self iprintln("^3Timeout on next round start: sideswitch");
        return;
    }
    if (game["promod_timeout_called"])
    {
        if (isDefined(game["promod_timeout_called_by"]))
        {
            if (self == game["promod_timeout_called_by"])
            {
                iprintln("^3Timeout cancelled by " + self.name);
                if (level.gametype == "sd")
                    game[self.pers["team"] + "_timeout_called"] = 0;
                game["promod_timeout_called"] = false;
            }
            else
                self iprintln("^3Timeout already called by " + game["promod_timeout_called_by"].name);
        }
        else
            self iprintln("^3Timeout already called");
        return;
    }
    if (game[self.pers["team"] + "_timeout_called"] && (!isDefined(game["LAN_MODE"]) || !game["LAN_MODE"]))
    {
        self iprintln("^3Only one timeout per team/half allowed");
        return;
    }
    game["promod_timeout_called_by"] = self;
    iprintln("^3Timeout called by " + self.name);
    if (!isDefined(level.strat_over) || level.strat_over)
        self iprintln("^3Call timeout again to cancel timeout");
    if (level.gametype == "sd")
        game[self.pers["team"] + "_timeout_called"] = 1;
    game["promod_timeout_called"] = true;
}