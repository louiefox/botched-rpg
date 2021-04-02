BOTCHED.CONFIG = {}

-- NOTICES CONFIG --
BOTCHED.CONFIG.NoticeTypes = {
    [1] = { 
        Name = "Announcement",
        Color = Color(192, 57, 43)
    },
    [2] = { 
        Name = "Update",
        Color = Color(192, 57, 43)
    },
    [3] = { 
        Name = "Event",
        Color = Color(39, 174, 96)
    },
    [4] = { 
        Name = "Gacha",
        Color = Color(243, 156, 18)
    },
    [5] = { 
        Name = "Issue",
        Color = Color(41, 128, 185)
    }
}
BOTCHED.CONFIG.Notices = {
    {
        Header = "Join our discord!",
        Time = 1617200970,
        Type = 3,
        Image = "https://i.imgur.com/W7J57gc.jpg",
        HTML = [[
            <b>There will be rewards for joining our discord at some point and for helping during the beta!</b>
            <p>Make sure to join the discord <a href="" onclick='console.log("RUNLUA:gui.OpenURL(\"https://discord.gg/NAaTvpK8vQ\")")'>https://discord.gg/NAaTvpK8vQ</a></p>
        ]]
    },
    {
        Header = "Beta Access",
        Time = 1617200957,
        Type = 1,
        Image = "https://i.imgur.com/XHuIUwZ.png",
        HTML = [[
            <b>Thanks for joining during the beta!</b>
            <p>Please keep in mind that there may be bugs and a lot is subject to change :)</p>
        ]]
    }
}

-- BANNERS CONFIG --
BOTCHED.CONFIG.AlreadyOwnedRefunds = {
    [1] = 1,
    [2] = 10,
    [3] = 50
}
BOTCHED.CONFIG.Banners = {
    [1] = { 
        Name = "Anime Banner",
        Image = "https://i.imgur.com/Jft6gM8.jpg",
        Draws = {
            {
                Amount = 1,
                Cost = {
                    Gems = 150
                }
            },
            {
                Amount = 10,
                Cost = {
                    Gems = 1500
                }
            }
        },
        Characters = { "god_eater", "zero_two", "mei_sakurajima_1" },
        Chances = {
            [1] = {
                Chance = 79.5
            },
            [2] = {
                Chance = 18
            },
            [3] = {
                Chance = 2.5,
                FocusedMultiplier = 4,
            }
        }
    },
    [2] = { 
        Name = "In-Human Banner",
        Image = "https://i.imgur.com/XV0E0zn.jpg",
        Draws = {
            {
                Amount = 1,
                Cost = {
                    Gems = 150
                }
            },
            {
                Amount = 10,
                Cost = {
                    Gems = 1500
                }
            }
        },
        Characters = { "thresh", "lizardmanshaman", "darkwraith" },
        Chances = {
            [1] = {
                Chance = 79.5
            },
            [2] = {
                Chance = 18
            },
            [3] = {
                Chance = 2.5,
                FocusedMultiplier = 4,
            }
        }
    }
}

-- THEME CONFIG --
BOTCHED.CONFIG.Themes = {}
BOTCHED.CONFIG.Themes[1] = Color( 34, 40, 49 )
BOTCHED.CONFIG.Themes[2] = Color( 57, 62, 70 )
BOTCHED.CONFIG.Themes[3] = Color( 0, 173, 181 )
BOTCHED.CONFIG.Themes[4] = Color( 238, 238, 238 )

BOTCHED.CONFIG.Themes.Bronze = Color( 176, 122, 60 )
BOTCHED.CONFIG.Themes.Silver = Color( 165, 165, 165 )
BOTCHED.CONFIG.Themes.Gold = Color( 222, 175, 7 )
BOTCHED.CONFIG.Themes.Diamond = Color( 0, 255, 233 )

BOTCHED.CONFIG.Themes.Red = Color( 231, 76, 60 )
BOTCHED.CONFIG.Themes.DarkRed = Color( 192, 57, 43 )

BOTCHED.CONFIG.Themes.Blue = Color( 52, 152, 219 )
BOTCHED.CONFIG.Themes.DarkBlue = Color( 41, 128, 185 )

BOTCHED.CONFIG.Themes.Orange = Color( 243, 156, 18 )
BOTCHED.CONFIG.Themes.DarkOrange = Color( 230, 126, 34 )

-- BORDER COLORS CONFIG --
BOTCHED.CONFIG.Borders = {}
BOTCHED.CONFIG.Borders.Bronze = { Order = 1, Colors = { Color( 250, 158, 117 ), Color( 249, 220, 186 ), Color( 220, 126, 74 ), Color( 250, 186, 151 ) } }
BOTCHED.CONFIG.Borders.Silver = { Order = 2, Colors = { Color( 196, 203, 209 ), Color( 255, 254, 255 ), Color( 180, 181, 212 ), Color( 219, 235, 250 ) } }
BOTCHED.CONFIG.Borders.Gold = { Order = 3, Colors = { Color( 252, 205, 117 ), Color( 249, 249, 151 ), Color( 243, 178, 62 ), Color( 255, 223, 122 ) } }
BOTCHED.CONFIG.Borders.Diamond = { Order = 4, Colors = { Color( 134, 240, 240 ), Color( 141, 252, 252 ), Color( 81, 196, 196 ), Color( 135, 245, 245 ) } }

local rainbowColors, range = {}, 10
for i = 1, range do
    table.insert( rainbowColors, HSVToColor( (i/range)*360, 1, 1 ) )
end

BOTCHED.CONFIG.Borders.Rainbow = { Order = 5, Colors = rainbowColors, Anim = true }

-- TIME REWARD CONFIG --
BOTCHED.CONFIG.TimeRewards = {
    [1] = {
        Time = 900,
        Reward = {
            Gems = 150
        }
    },
    [2] = {
        Time = 1800,
        Reward = {
            Gems = 200
        }
    },
    [3] = {
        Time = 3600,
        Reward = {
            Characters = { "link" }
        }
    },
    [4] = {
        Time = 3600*2,
        Reward = {
            Gems = 500
        }
    },
    [5] = {
        Time = 3600*4,
        Reward = {
            Gems = 800,
        }
    },
    [6] = {
        Time = 3600*8,
        Reward = {
            Mana = 25000
        }
    },
    [7] = {
        Time = 3600*16,
        Reward = {
            Gems = 1000
        }
    },
    [8] = {
        Time = 3600*24,
        Reward = {
            Characters = { "astolfo_sch" }
        }
    },
    [9] = {
        Time = 3600*24*2,
        Reward = {
            Gems = 1500
        }
    },
    [10] = {
        Time = 3600*24*4,
        Reward = {
            Gems = 2000
        }
    },
    [11] = {
        Time = 3600*24*7,
        Reward = {
            Gems = 3000
        }
    },
    [12] = {
        Time = 3600*24*14,
        Reward = {
            Gems = 4500
        }
    },
    [13] = {
        Time = 3600*24*28,
        Reward = {
            Gems = 6000
        }
    }
}

-- LOGIN REWARD CONFIG --
BOTCHED.CONFIG.LoginRewards = {
    [1] = { Gems = 25 },
    [2] = { Mana = 15000 },
    [3] = { Items = { ["refinement_crystal_2"] = 1 } },
    [4] = { Gems = 50 },
    [5] = { Mana = 30000 },

    [6] = { Gems = 50 },
    [7] = { Mana = 20000 },
    [8] = { Items = { ["refinement_crystal_2"] = 2 } },
    [9] = { Gems = 100 },
    [10] = { Mana = 45000 },

    [11] = { Gems = 75 },
    [12] = { Mana = 25000 },
    [13] = { Items = { ["refinement_crystal_2"] = 3 } },
    [14] = { Gems = 150 },
    [15] = { Mana = 60000 },

    [16] = { Gems = 25 },
    [17] = { Mana = 15000 },
    [18] = { Items = { ["refinement_crystal_2"] = 1 } },
    [19] = { Gems = 50 },
    [20] = { Mana = 30000 },

    [21] = { Gems = 50 },
    [22] = { Mana = 20000 },
    [23] = { Items = { ["refinement_crystal_2"] = 2 } },
    [24] = { Gems = 100 },
    [25] = { Mana = 45000 },
    
    [26] = { Gems = 75 },
    [27] = { Mana = 25000 },
    [28] = { Items = { ["refinement_crystal_2"] = 3 } },
    [29] = { Gems = 150 },
    [30] = { Mana = 60000 }
}

-- MAP CONFIG --
BOTCHED.CONFIG.Map = {
    LocationTitles = {
        ["Blackrock Castle"] = Vector( -7155, 8666, -1493 ),
        ["Iron Mine"] = Vector( -7775, 778, -2929 ),
        ["Outpost"] = Vector( -4616, -6498, -2893 ),
        ["Redwater Dungeon"] = Vector( 9649, -9410, -2941 ),
        ["Undead Camp"] = Vector( 9957, 7445, -2973 )
    },
    Teleports = {
        {
            Title = "Blackrock Castle",
            Pos = Vector( -5518, 8048, -1571 ),
            Duration = 5
        },
        {
            Title = "Iron Mine",
            Pos = Vector( -7544, 1477, -2941 ),
            Duration = 5
        },
        {
            Title = "Outpost",
            Pos = Vector( -4603, -5857, -2863 ),
            Duration = 5
        }
    }
}

-- SPAWN POINTS CONFIG --
BOTCHED.CONFIG.SpawnPoints = {
    Vector( -4626, -6636, -3039 ),
    Vector( -7544, 1477, -2941 )
}

-- CHAT HINTS CONFIG --
BOTCHED.CONFIG.ChatHints = {
    "Press 'M' to open the world map and see your location as well as other useful locations.",
    "You can holster your weapon with the reload key (R).",
    "You can press 'Q' or 'F4' to open the main menu.",
    "Stamina is replenished by 1 every minute, even when you disconnect!",
    "You can receive rewards for time played on the server, check the main menu!",
    "You can get rewards for logging in to the server daily. To see and claim your rewards click the 'Login Rewards' button in the main menu.",
    "Put // before your chat message to use global chat so everyone can see your message."
}