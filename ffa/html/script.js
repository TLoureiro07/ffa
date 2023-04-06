var datasetvar;
var kd = 0;
var id = 0;
var allzones;
var categories = ["x", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"];
var columns = ["data", 0, 82, 10, 42, 20, 62];
var lines = [
  { value: 0 },
  { value: 1 },
  { value: 2 },
  { value: 3 },
  { value: 4 },
  { value: 5 },
  { value: 6 },
  { value: 7 },
  { value: 8 },
  { value: 9 },
  { value: 10 },
];

var gamemode;
var card;
var cash;

var playtime;
var actualplaytime = null;
var playtimertimer;

var hudtimer;

let playerlist = [];

var leaderboardmaxplayer = 0;

document.querySelector(".leaderboard .loading-circle").style.display = "block";
document.querySelector(".gui .profile-settings .loading-circle").style.display =
  "block";

function preloadImages(srcs) {
  function loadImage(src) {
    return new Promise(function (resolve, reject) {
      var img = new Image();
      img.onload = function () {
        resolve(img.currentSrc);
      };
      img.onerror = img.onabort = function (e) {
        resolve("http://i.imgur.com/gsnPQRw.png");
      };
      img.src = src;
    });
  }
  var promises = [];
  for (var i = 0; i < playerlist.length; i++) {
    promises.push(loadImage(srcs[i]));
  }
  return Promise.all(promises);
}

var topdownbutton = false;
var topdown = false;
$(".top-down-button").click(function (e) {
  topdownbutton = !topdownbutton;
  if (!topdownbutton) {
    $(".gui .leaderboard .top-down-button").removeClass("mirror");
    $(".gui .leaderboard .top-down-button").addClass("mirror2");
    topdown = false;
    leaderboardClick(datasetvar, topdown);
  } else {
    $(".gui .leaderboard .top-down-button").removeClass("mirror2");
    $(".gui .leaderboard .top-down-button").addClass("mirror");
    topdown = true;
    leaderboardClick(datasetvar, topdown);
  }
});

let profileinput;
let nameinput;

function setprofilename(input) {
  nameinput = input;
  if (event.keyCode == 13) {
    if (!hasWhiteSpace(input.value) && input.value != "") {
      for (let i = 0; i < playerlist.length; i++) {
        if (playerlist[i].self == 1) {
          playerlist[i].name = input.value;
          leaderboardClick(datasetvar, topdown);
          $.post(
            "http://ffa/ffa:updateusername",
            JSON.stringify({
              name: input.value,
            })
          );
          input.style.border =
            "1px dashed " +
            window
              .getComputedStyle(document.documentElement)
              .getPropertyValue("--border-color");
          input.value = "";
        }
      }
    } else {
      input.style.border =
        "1px solid " +
        window
          .getComputedStyle(document.documentElement)
          .getPropertyValue("--input-warning-color");
    }
  }
}

function hasWhiteSpace(s) {
  return s.indexOf(" ") >= 0;
}

function setprofile(input) {
  profileinput = input;
  if (event.keyCode == 13) {
    testImage(input.value)
      .then((result) => {
        if (result) {
          for (let i = 0; i < playerlist.length; i++) {
            if (playerlist[i].self == 1) {
              playerlist[i].url = input.value;
              leaderboardClick(datasetvar, topdown);
            }
          }
          $.post(
            "http://ffa/ffa:updateprofilepicture",
            JSON.stringify({
              picture: input.value,
            })
          );
          input.style.border =
            "1px dashed " +
            window
              .getComputedStyle(document.documentElement)
              .getPropertyValue("--border-color");
          input.value = "";
        }
      })
      .catch((err) => {
        input.style.border =
          "1px solid " +
          window
            .getComputedStyle(document.documentElement)
            .getPropertyValue("--input-warning-color");
      });
  }
}

$(".settings").click(function (e) {
  var btn = $(this);
  btn.prop("disabled", true);
  setTimeout(function () {
    btn.prop("disabled", false);
  }, 900);
  if ($(".gui .right-items").hasClass("settingsopen")) {
    $(".gui .settings-items").addClass("closesettings");
    setTimeout(function () {
      $(".gui .right-items").addClass("settingsclose");
    }, 550);
    setTimeout(function () {
      $(".gui .settings-items").removeClass("opensettings");
      $(".gui .right-items").removeClass("settingsopen");
      setTimeout(function () {
        $(".gui .settings-items").removeClass("closesettings");
        $(".gui .right-items").removeClass("settingsclose");
      }, 450);
    }, 550);
  }
  if (colorpicker.classList.contains("show")) {
    colorpicker.classList.toggle("show");
  }
  $(".gui .settings-items").addClass("opensettings");
  $(".gui .right-items").addClass("settingsopen");
});

$(".close-button").click(function (e) {
  setoptionstodatabase();

  $.post(
    "http://ffa/ffa:menu",
    JSON.stringify({
      bool: false,
    })
  );
  try {
    profileinput.style.border =
      "1px dashed " +
      window
        .getComputedStyle(document.documentElement)
        .getPropertyValue("--border-color");
    profileinput.value = "";
    nameinput.style.border =
      "1px dashed " +
      window
        .getComputedStyle(document.documentElement)
        .getPropertyValue("--border-color");
    nameinput.value = "";
  } catch (error) {}

  $(".gui .settings-items").removeClass("opensettings");
  $(".gui .right-items").removeClass("settingsopen");
});

var gamestatus = document.createElement("div");
gamestatus.classList.add("status");
gamestatus.innerHTML = "(Ausgewählt)";

function cardselectbutton(object) {
  $(".activee").each(function (i) {
    $(this).removeClass("activee");
  });
  var main = object.closest(".card");
  card = main.id;
  updateSelected(1);
  main.classList.add("activee");
}
function gamesselectbutton(object) {
  var main = object.closest(".main").id;
  var cashdiv = document.getElementById(main).children[1];
  document.getElementById(main).appendChild(gamestatus);
  gamemode = main;
  cash = cashdiv.children[0].textContent;
  updateSelected(0);
}
$(".card .select-button").click(function () {
  $(".activee").each(function (i) {
    $(this).removeClass("activee");
  });
  var main = $(this).closest(".card");
  card = main.attr("id");
  updateSelected(1);
  main.addClass("activee");
});
$(".games .select-button").click(function (e) {
  var main = $(this).closest(".main").attr("id");
  var cashdiv = document.getElementById(main).children[1];
  document.getElementById(main).appendChild(gamestatus);
  gamemode = main;
  cash = cashdiv.children[0].textContent;
  updateSelected(0);
});
$(".select-border .start-button").click(function (e) {
  updateSelected(2);
});

function addChartElement(num, time) {
  number = num;
  columns.splice(1, 1);
  columns.push(number);
  categories.shift();
  categories.push(time);

  if (columns.length < 7) {
    number = Math.floor(Math.random() * 500 + 1);
    columns.push(number);
  }
  traffic.load({
    columns: [columns],
  });

  $.post(
    "http://ffa/ffa:saveChart",
    JSON.stringify({
      columns: columns,
    })
  );
}

var count;
var zonecount;

function setupmenu(data) {
  let avatarlist = [];
  playerlist = data.allusers;

  leaderboardmaxplayer = data.leaderboardmaxplayer;

  for (let i = 0; i < playerlist.length; i++) {
    if (playerlist[i].self == 1) {
      if (playerlist[i].options != "[]") {
        document.querySelectorAll(".player-setting").forEach(function (elem) {
          let boolValue = playerlist[i].options[elem.id] == "true";
          elem.checked = boolValue;
        });
      } else {
        playerlist[i].options = data.options;
        document.querySelectorAll(".player-setting").forEach(function (elem) {
          let boolValue = playerlist[i].options[elem.id];
          elem.checked = boolValue;
        });
        setoptionstodatabase();
      }
    }
  }

  for (let i = 0; i < playerlist.length; i++) {
    //console.log(playerlist[i].url + " NAME: " + playerlist[i].name);
    avatarlist.push(playerlist[i].url);
  }

  //console.log(JSON.stringify(avatarlist));

  count = data.respawncountdown;
  zonecount = data.outzonecountdown;

  for (let i = 0; i < playerlist.length; i++) {
    avatarlist.push(playerlist[i].url);
  }

  preloadImages(avatarlist).then(function (imgs) {
    for (var i = 0; i < playerlist.length; i++) {
      playerlist[i].url = imgs[i];
    }
    calculateKD();
    datasetvar = "kills";
    document.querySelector(".leaderboard .loading-circle").style.display =
      "none";
    document.querySelector(
      ".gui .profile-settings .loading-circle"
    ).style.display = "none";
    document.querySelector(
      ".gui .profile-settings .picture img"
    ).style.opacity = 1;
    document.querySelector(".bestplayer-list").style.visibility = "visible";
    updateLeaderboardView(datasetvar, false);
  });

  var servernames = document.getElementsByName("servername");
  for (let i = 0; i < servernames.length; i++) {
    servernames[i].textContent = data.servername;
  }

  var cardlist = document.querySelector(".card-list");
  cardlist.innerHTML = "";
  var zones = data.zones;
  $.each(zones, function (i, z) {
    allzones = zones[i];
    var name = zones[i].Name;
    var desc = zones[i].Desc;
    var date = zones[i].AddedDate;
    var max = zones[i].MaxPlayers;

    createZone(name, desc, date, max);
  });

  $.post("http://ffa/ffa:started", JSON.stringify({}));
}

function respawnplayer(deathReason) {
  if (deathReason == "gestorben") {
    document.getElementById("respawnmsg").innerText = "DU BIST GESTORBEN!";
    $.post(
      "http://ffa/ffa:sendNotification",
      JSON.stringify({ text: "Du bist gestorben!" })
    );
  } else {
    document.getElementById("respawnmsg").innerHTML =
      "DU WURDEST VON <span> " + deathReason + "</span> GETÖTET!";
    $.post(
      "http://ffa/ffa:sendNotification",
      JSON.stringify({ text: "Du wurdest von " + deathReason + " getötet!" })
    );
  }
  document.querySelector(".respawn").style.opacity = "1";

  var timeleft = count;
  document.getElementById("respawnmsg2").innerHTML =
    " RESPAWN IN <span>" + timeleft + "</span> SEKUNDEN";
  timeleft--;
  var timer = setInterval(function () {
    document.getElementById("respawnmsg2").innerHTML =
      " RESPAWN IN <span>" + timeleft + "</span> SEKUNDEN";
    if (timeleft == 0) {
      $.post("http://ffa/ffa:respawn", JSON.stringify({}));
      clearInterval(timer);
    }
    timeleft -= 1;
  }, 1000);
}

var timer;

function inzoneout(data) {
  var timeleft = zonecount;
  if (!data.state) {
    document.querySelector(".out-zone").style.opacity = "1";
    document.getElementById("zoneoutmsg").innerHTML =
      " RESPAWN IN <span>" + timeleft + "</span> SEKUNDEN";
    timeleft--;
    timer = setInterval(function () {
      document.getElementById("zoneoutmsg").innerHTML =
        " RESPAWN IN <span>" + timeleft + "</span> SEKUNDEN";
      if (timeleft <= 0) {
        $.post("http://ffa/ffa:respawn", JSON.stringify({}));
        clearInterval(timer);
      }
      timeleft -= 1;
    }, 1000);
  } else {
    clearInterval(timer);
    document.querySelector(".out-zone").style.opacity = "0";
  }
}

var datass = [
  ["x", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"],
  ["data", generateRandomNumber(), generateRandomNumber()],
];

function generateRandomNumber() {
  return Math.floor(Math.random() * 10 + 1);
}

var colorpicker = document.querySelector(".color-picker-panel");
$(document).ready(function () {
  window.addEventListener("message", function (event) {
    if (event.data.type == "menu") {
      columns = [];
      categories = [];
      if (event.data.status) {
        document.querySelector(".back").style.opacity = "1";
      } else {
        document.querySelector(".back").style.opacity = "0";

        try {
          profileinput.style.border =
            "1px dashed " +
            window
              .getComputedStyle(document.documentElement)
              .getPropertyValue("--border-color");
          profileinput.value = "";
          nameinput.style.border =
            "1px dashed " +
            window
              .getComputedStyle(document.documentElement)
              .getPropertyValue("--border-color");
          nameinput.value = "";
        } catch (error) {}

        $(".gui .settings-items").removeClass("opensettings");
        $(".gui .right-items").removeClass("settingsopen");

        if (colorpicker.classList.contains("show")) {
          colorpicker.classList.toggle("show");
        }
      }
    } else if (event.data.type == "menudata") {
      setupmenu(event.data);
    } else if (event.data.type == "refreshmenu") {
      refreshmenu(event.data);
    } else if (event.data.type == "respawn") {
      respawnplayer(event.data.DeathReason);
    } else if (event.data.type == "closerespawn") {
      document.querySelector(".respawn").style.opacity = "0";
    } else if (event.data.type == "inzoneout") {
      inzoneout(event.data);
    } else if (event.data.type == "hud") {
      if (event.data.status) {
        $(".hud .wrapper").removeClass("invisible");
        $(".hud .wrapper").addClass("visible");
        $(".hud .left-circle").addClass("left-circle-animationclass");
        $(".hud .right-circle").addClass("right-circle-animationclass");
      } else {
        $(".hud .wrapper").addClass("invisible");
        $(".hud .wrapper").removeClass("visible");
        setTimeout(function () {
          $(".hud .left-circle").removeClass("left-circle-animationclass");
          $(".hud .right-circle").removeClass("right-circle-animationclass");
        }, 500);
        clearInterval(hudtimer);
      }
    } else if (event.data.type == "getplayerdata") {
      if (actualplaytime != null) {
        updateplayerdata();
      }
    } else if (event.data.type == "quitffa") {
      quitffa();
    } else if (event.data.type == "addKill") {
      addKill(event.data.identifier);
    } else if (event.data.type == "addDeath") {
      addDeath(event.data.identifier);
    } else if (event.data.type == "setCount") {
      document.querySelector(".hud .player .value").textContent =
        event.data.count + "/" + event.data.max;
    } else if (event.data.type == "setCount2") {
      const nodeList = document.querySelectorAll(".header-user");
      for (let i = 0; i < nodeList.length; i++) {
        if (nodeList[i].id == event.data.name) {
          nodeList[i].textContent = event.data.count + "/" + event.data.max;
        }
      }
    } else if (event.data.type == "refreshchart") {
      // addChartElement(event.data.newadd, event.data.time);
    } else if (event.data.type == "setchart") {
      columns.push(event.data.columns);
      // console.log(columns);

      traffic.load({
        columns: [categories, columns],
      });
    } else if (event.data.type == "setcategory") {
      categories.push(event.data.category);
      traffic.load({
        columns: [categories, columns],
      });
    } else if (event.data.type == "setallcount") {
      document.querySelector(".total-player").textContent =
        event.data.count + " Ingesamte Spieler in FFA";
    }
  });
});

function setoptionstodatabase() {
  var options = {};

  for (let i = 0; i < playerlist.length; i++) {
    if (playerlist[i].self == 1) {
      document.querySelectorAll(".player-setting").forEach(function (elem) {
        options[elem.id] = elem.checked;
      });
    }
  }
  $.post(
    "http://ffa/ffa:setoptionstodatabase",
    JSON.stringify({
      options: options,
    })
  );
}

function addKill(identifier) {
  for (let i = 0; i < playerlist.length; i++) {
    if (playerlist[i].identifier == identifier) {
      playerlist[i].kills += 1;
    }
  }
  calculateKD();
}

function addDeath(identifier) {
  for (let i = 0; i < playerlist.length; i++) {
    if (playerlist[i].identifier == identifier) {
      playerlist[i].deaths += 1;
    }
  }
  calculateKD();
}

function updateplayerdata() {
  for (let i = 0; i < playerlist.length; i++) {
    if (playerlist[i].self == 1) {
      playerlist[i].playtime = actualplaytime;
      $.post(
        "http://ffa/ffa:updateplayerdata",
        JSON.stringify({
          playerdata: playerlist[i],
        })
      );
    }
  }
}

function quitffa() {
  updateplayerdata();
  clearInterval(playtimertimer);
  clearInterval(hudtimer);
  document.querySelector(".hud .playtime .value").textContent = "00:00";
}

function refreshmenu(data) {
  let avatarlist = [];
  playerlist = data.allusers;

  for (let i = 0; i < playerlist.length; i++) {
    if (playerlist[i].self == 1) {
      if (playerlist[i].options != "[]") {
        document.querySelectorAll(".player-setting").forEach(function (elem) {
          let boolValue = playerlist[i].options[elem.id] == "true";
          elem.checked = boolValue;
        });
      } else {
        playerlist[i].options = data.options;
        document.querySelectorAll(".player-setting").forEach(function (elem) {
          let boolValue = playerlist[i].options[elem.id];
          elem.checked = boolValue;
        });
      }
      setoptionstodatabase();
    }
  }

  var gamelist = document.querySelector(".games-list");
  gamelist.innerHTML = "";
  var gamemodes = data.gamemodes;
  $.each(gamemodes, function (i, z) {
    var name = gamemodes[i].Name;
    var desc = gamemodes[i].Desc;
    var death = gamemodes[i].Death;
    var killreward = gamemodes[i].KillReward;
    var joinprice = gamemodes[i].JoinPrice;

    createGamemode(name, desc, killreward, joinprice, death);
  });

  var gmlist = document.querySelectorAll(".games");
  if (gmlist.length > 2) {
    gmlist.forEach((element) => {
      element.style.margin = "5px";
    });
  }

  for (let i = 0; i < playerlist.length; i++) {
    avatarlist.push(playerlist[i].url);
  }

  preloadImages(avatarlist).then(function (imgs) {
    for (var i = 0; i < playerlist.length; i++) {
      playerlist[i].url = imgs[i];
    }
    calculateKD();
    datasetvar = "kills";
    document.querySelector(".leaderboard .loading-circle").style.display =
      "none";
    document.querySelector(
      ".gui .profile-settings .loading-circle"
    ).style.display = "none";
    document.querySelector(
      ".gui .profile-settings .picture img"
    ).style.opacity = 1;
    document.querySelector(".bestplayer-list").style.visibility = "visible";
    updateLeaderboardView(datasetvar, false);
  });
}

var formatter = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
  maximumFractionDigits: 0,
});

function createZone(name, desc, date, max) {
  var cardlist = document.querySelector(".card-list");

  let card = document.createElement("article");
  card.classList.add("card");
  card.id = name;

  let shine = document.createElement("div");
  shine.classList.add("shine");

  let cardheader = document.createElement("div");
  cardheader.classList.add("card-header");

  let headertext = document.createElement("div");
  headertext.classList.add("header-text");
  headertext.innerText = name;

  let headeruser = document.createElement("div");
  headeruser.classList.add("header-user");
  headeruser.innerText = "0/" + max;
  headeruser.id = name;

  let main = document.createElement("div");
  main.classList.add("main");

  let description = document.createElement("div");
  description.classList.add("description");
  description.innerText = desc;

  let addedate = document.createElement("div");
  addedate.classList.add("added-date");
  addedate.innerText = date;

  let selectbutton = document.createElement("div");
  selectbutton.classList.add("select-button");
  selectbutton.innerHTML = "<span>Auswählen</span>";
  selectbutton.setAttribute("onclick", "cardselectbutton(this);");

  cardlist.appendChild(card);
  card.appendChild(shine);
  card.appendChild(cardheader);
  cardheader.appendChild(headertext);
  cardheader.appendChild(headeruser);

  card.appendChild(main);
  main.appendChild(description);

  card.appendChild(addedate);

  card.appendChild(selectbutton);
}

function createGamemode(modename, desc, killreward, joinprice, death) {
  var gamelist = document.querySelector(".games-list");

  let game = document.createElement("article");
  game.classList.add("games");

  let bottomglow = document.createElement("div");
  bottomglow.classList.add("bottom-glow2");

  let header = document.createElement("div");
  header.classList.add("header");

  let title = document.createElement("div");
  title.classList.add("title");
  title.innerText = modename;

  let main = document.createElement("div");
  main.classList.add("main");
  main.id = modename;

  let description = document.createElement("div");
  description.classList.add("description");
  description.innerHTML = desc;

  let icon = document.createElement("i");
  icon.classList.add("far");
  icon.classList.add("fa-question-circle");

  let circle = document.createElement("div");
  circle.classList.add("circle-hover");

  let circletext = document.createElement("div");
  circletext.classList.add("text");
  circletext.innerHTML =
    "Eintrittspreis: <span>" +
    formatter.format(joinprice) +
    "</span><br />Eliminierungs belohnung: <span>" +
    formatter.format(killreward) +
    "</span><br />Todesstrafe: <span>" +
    death +
    "</span>";

  let description2 = document.createElement("div");
  description2.classList.add("description2");
  description2.innerHTML =
    "Eintrittspreis: <span>" +
    formatter.format(joinprice) +
    "</span><br />Eliminierungs belohnung: <span>" +
    formatter.format(killreward) +
    "</span>";

  let selectbutton = document.createElement("div");
  selectbutton.classList.add("select-button");
  selectbutton.innerHTML = "<span>Auswählen</span><span>></span>";
  selectbutton.setAttribute("onclick", "gamesselectbutton(this);");

  gamelist.appendChild(game);
  game.appendChild(bottomglow);
  game.appendChild(header);
  header.appendChild(title);

  game.appendChild(main);
  main.appendChild(description);
  description.appendChild(icon);
  icon.appendChild(circle);
  circle.appendChild(circletext);

  main.appendChild(description2);
  main.appendChild(selectbutton);
}

var gradientSteps = {
  "0%": window
    .getComputedStyle(document.documentElement)
    .getPropertyValue("--chart-gradientstep-color1"),
  "33%": window
    .getComputedStyle(document.documentElement)
    .getPropertyValue("--chart-gradientstep-color2"),
  "100%": window
    .getComputedStyle(document.documentElement)
    .getPropertyValue("--chart-gradientstep-color3"),
};
var gradientDirection = "h";

var traffic = c3.generate({
  bindto: "#traffic-chart",
  padding: {
    left: 10,
    right: 10,
  },
  size: {
    width: 260,
    height: 100,
  },
  data: {
    x: "x",
    columns: [categories, columns],

    types: {
      data: "spline",
    },
  },
  zoom: {
    enabled: false,
  },
  grid: {
    x: {
      lines: lines,
    },
  },
  axis: {
    y: {
      show: false,
    },
    x: {
      show: true,
      type: "category",
      // categories: categories,
    },
  },
  legend: {
    show: false,
  },
  tooltip: {
    show: true,
  },
  point: {
    show: false,
  },
});

function svgElement(element, attr) {
  el = $(document.createElementNS("http://www.w3.org/2000/svg", element));
  return el.attr(attr);
}

if (gradientDirection == "v") {
  var x2 = "0%";
  var y1 = "100%";
} else if (gradientDirection == "h") {
  var x2 = "100%";
  var y1 = "0%";
}

var grad = svgElement("linearGradient", {
  id: "bgGradient",
  x1: "0%",
  x2: x2,
  y1: y1,
  y2: "0%",
}).appendTo("#traffic-chart svg defs");

$.each(gradientSteps, function (offset, color) {
  svgElement("stop", {
    style: "stop-color:" + gradientSteps[offset],
    offset: offset,
  }).appendTo("#traffic-chart svg defs #bgGradient");
});

var updateLeaderboardView = function (value, bool) {
  calculateKD();

  let leaderboard = document.querySelector(".bestplayer-list");
  leaderboard.innerHTML = "";

  if (datasetvar == "kills")
    document.querySelector(".leaderboard .under-title").innerHTML = "Top Kills";
  if (datasetvar == "deaths")
    document.querySelector(".leaderboard .under-title").innerHTML = "Top Tode";
  if (datasetvar == "kd")
    document.querySelector(".leaderboard .under-title").innerHTML = "Top KD";

  if (bool) {
    playerlist.sort(function (a, b) {
      if (datasetvar == "kills") return a.kills - b.kills;
      if (datasetvar == "deaths") return a.deaths - b.deaths;
      if (datasetvar == "kd") return a.kd - b.kd;
    });
  } else {
    playerlist.sort(function (a, b) {
      if (datasetvar == "kills") return b.kills - a.kills;
      if (datasetvar == "deaths") return b.deaths - a.deaths;
      if (datasetvar == "kd") return b.kd - a.kd;
    });
  }

  let elements = [];
  for (let i = 0; i < parseInt(leaderboardmaxplayer); i++) {
    try {
      let overflow = document.createElement("div");
      let name = document.createElement("div");
      let value = document.createElement("div");
      let ranking = document.createElement("div");
      let pb = document.createElement("img");

      overflow.classList.add("overflow");
      name.classList.add("playername");
      value.classList.add("playerkills");
      pb.classList.add("profilepicture");
      ranking.classList.add("ranking");

      name.innerText = playerlist[i].name;

      if (datasetvar == "kills") value.innerText = playerlist[i].kills;
      if (datasetvar == "deaths") value.innerText = playerlist[i].deaths;
      if (datasetvar == "kd") value.innerText = playerlist[i].kd;
      ranking.innerText = i + 1;
      pb.src = playerlist[i].url;

      var scoreRow = document.createElement("div");
      scoreRow.classList.add("player");
      scoreRow.appendChild(overflow);
      overflow.appendChild(name);
      scoreRow.appendChild(value);
      scoreRow.appendChild(ranking);
      scoreRow.appendChild(pb);

      leaderboard.appendChild(scoreRow);
      elements.push(scoreRow);
    } catch (error) {}
  }

  let colors = [
    window
      .getComputedStyle(document.documentElement)
      .getPropertyValue("--leaderboard-top1-color"),
    window
      .getComputedStyle(document.documentElement)
      .getPropertyValue("--leaderboard-top2-color"),
    window
      .getComputedStyle(document.documentElement)
      .getPropertyValue("--leaderboard-top3-color"),
  ];
  try {
    for (let i = 0; i < playerlist.length; i++) {
      elements[i].style.background = colors[i];
      if (playerlist[i].self == 1) {
        elements[i].style.border =
          "1.5px solid " +
          window
            .getComputedStyle(document.documentElement)
            .getPropertyValue("--leaderboard-self-border-color");
      } else {
        elements[i].style.border = "1.5px solid " + colors[i];
      }
      elements[i].style.color = "rgb(19, 19, 19)";
    }
  } catch (error) {}
};

var calculateKD = function () {
  for (let i = 0; i < playerlist.length; i++) {
    if (playerlist[i].kills == 0 && playerlist[i].deaths == 0) {
      kd = "0.0";
    } else if (playerlist[i].deaths == 0) {
      kd = playerlist[i].kills;
    } else {
      kd = parseFloat((playerlist[i].kills / playerlist[i].deaths).toFixed(2));
      if (kd == 0) {
        kd = kd + ".0";
      }
    }

    playerlist[i].kd = kd;
    if (playerlist[i].self == 1) {
      let img = document.querySelector(
        ".gui .wrapper .main-left .profile-settings .picture img"
      );
      img.src = playerlist[i].url;
      let div = document.querySelector(
        ".gui .wrapper .main-left .profile-settings .picture .name"
      );
      let text = document.querySelector(
        ".gui .wrapper .main-left .profile-settings .picture .name .text"
      );
      div.textContent = playerlist[i].name;
      document.getElementById("kills").textContent = playerlist[i].kills;
      document.getElementById("deaths").textContent = playerlist[i].deaths;
      document.getElementById("kd").textContent = playerlist[i].kd;

      actualplaytime = playerlist[i].playtime;
      converttime(actualplaytime);

      text.textContent =
        "Spielzeit: " +
        playtime +
        "; KD: " +
        playerlist[i].kd +
        "; Kills: " +
        playerlist[i].kills +
        "; Tode: " +
        playerlist[i].deaths;
      div.appendChild(text);
    }
  }
};

var updateSelected = function (vars) {
  if (vars == 0) {
    const gamemodediv = document.querySelector(
      ".gui .wrapper .main-class .select-border .text .gamemode span"
    );
    gamemodediv.style.background =
      "-webkit-linear-gradient( -135deg, " +
      window
        .getComputedStyle(document.documentElement)
        .getPropertyValue("--primary-color-gradient") +
      ", " +
      window
        .getComputedStyle(document.documentElement)
        .getPropertyValue("--second-color-gradient") +
      ")";
    gamemodediv.style.webkitBackgroundClip = "text";
    gamemodediv.style.webkitTextFillColor = "transparent";
    gamemodediv.textContent = gamemode;
    const cashdiv = document.querySelector(
      ".gui .wrapper .main-class .select-border .text .cash span"
    );

    cashdiv.style.background =
      "-webkit-linear-gradient( -135deg, " +
      window
        .getComputedStyle(document.documentElement)
        .getPropertyValue("--primary-color-gradient") +
      ", " +
      window
        .getComputedStyle(document.documentElement)
        .getPropertyValue("--second-color-gradient") +
      ")";
    cashdiv.style.webkitBackgroundClip = "text";
    cashdiv.style.webkitTextFillColor = "transparent";
    cashdiv.textContent = cash;
    if (gamemode != null) {
      $(".games").each(function (i) {
        $(this).removeClass("warning");
      });
    }
  } else if (vars == 1) {
    const zonediv = document.querySelector(
      ".gui .wrapper .main-class .select-border .text .zone span"
    );
    zonediv.style.background =
      "-webkit-linear-gradient( -135deg, " +
      window
        .getComputedStyle(document.documentElement)
        .getPropertyValue("--primary-color-gradient") +
      ", " +
      window
        .getComputedStyle(document.documentElement)
        .getPropertyValue("--second-color-gradient") +
      ")";
    zonediv.style.webkitBackgroundClip = "text";
    zonediv.style.webkitTextFillColor = "transparent";
    zonediv.textContent = card;
    if (card != null) {
      $(".card").each(function (i) {
        $(this).removeClass("warning");
      });
    }
  } else if (vars == 2) {
    if (gamemode == null) {
      $(".games").each(function (i) {
        $(this).addClass("warning");
      });
    }
    if (card == null) {
      $(".card").each(function (i) {
        $(this).addClass("warning");
      });
    }
    if (card != null && gamemode != null) {
      joinzone();
    }
  }
};

function joinzone() {
  var options = {};

  for (let i = 0; i < playerlist.length; i++) {
    if (playerlist[i].self == 1) {
      document.querySelectorAll(".player-setting").forEach(function (elem) {
        options[elem.id] = elem.checked;
        if (elem.id == "fullplaytime") {
          if (elem.checked == true) {
            playtimeTimer(
              1 * playerlist[i].playtime,
              document.querySelector(".hud .playtime .value")
            );
          } else {
            playtimeTimer(1 * playerlist[i].playtime);
            startTimer(0, document.querySelector(".hud .playtime .value"));
          }
        }
      });
    }
  }
  $.post(
    "http://ffa/ffa:joinzone",
    JSON.stringify({
      zone: card,
      gamemode: gamemode,
    })
  );
  $.post(
    "http://ffa/ffa:setoptionstodatabase",
    JSON.stringify({
      options: options,
    })
  );
}

//gui timer
function playtimeTimer(start, display) {
  var timer = start,
    minutes,
    hours,
    days;
  playtimertimer = setInterval(function () {
    days = parseInt((timer / (3600 * 24)) | 0);
    minutes = parseInt((timer % 3600) / 60) | 0;
    hours = (parseInt(timer / 3600) - days * 24) | 0;

    minutes = minutes < 10 ? "0" + minutes : minutes;
    hours = hours < 10 ? "0" + hours : hours;

    timer++;
    actualplaytime = timer;
    if (hours == "00") {
      if (display != undefined) {
        display.textContent = "00:" + minutes;
      }
      playtime = minutes + "m";
    } else if (days != 0) {
      if (display != undefined) {
        display.textContent = days + ":" + hours + ":" + minutes;
      }
      playtime = days + "d " + hours + "h " + minutes + "m";
    } else {
      playtime = hours + "h " + minutes + "m";
      if (display != undefined) {
        display.textContent = hours + ":" + minutes;
      }
    }

    // console.log(timer + " GUI");
  }, 1000);
}

function converttime(time) {
  days = parseInt((time / (3600 * 24)) | 0);
  minutes = parseInt((time % 3600) / 60) | 0;
  hours = (parseInt(time / 3600) - days * 24) | 0;

  minutes = minutes < 10 ? "0" + minutes : minutes;
  hours = hours < 10 ? "0" + hours : hours;

  if (days != 0) {
    playtime = days + "d " + hours + "h " + minutes + "m";
  } else {
    playtime = hours + "h " + minutes + "m";
  }
}

function startTimer(start, display) {
  var timer = start,
    minutes,
    hours;
  hudtimer = setInterval(function () {
    minutes = parseInt((timer % 3600) / 60) | 0;
    hours = parseInt(timer / 3600) | 0;

    minutes = minutes < 10 ? "0" + minutes : minutes;
    hours = hours < 10 ? "0" + hours : hours;

    timer++;
    display.textContent = hours + ":" + minutes;
    // console.log(timer + " HUD");
  }, 1000);
}

function testImage(url, timeoutT) {
  return new Promise(function (resolve, reject) {
    var timeout = timeoutT || 5000;
    var timer,
      img = new Image();
    img.onerror = img.onabort = function () {
      clearTimeout(timer);
      reject(false);
    };
    img.onload = function () {
      clearTimeout(timer);
      resolve(true);
    };
    timer = setTimeout(function () {
      img.src = "//!!!!/noexist.jpg";
      reject(false);
    }, timeout);
    img.src = url;
  });
}

function togglecolorpicker() {
  colorpicker.classList.toggle("show");
}

var addSwatch = document.getElementById("add-swatch");
var modeToggle = document.getElementById("mode-toggle");
var swatches = document.getElementsByClassName("default-swatches")[0];
var colorIndicator = document.querySelector(".ccolor");
var userSwatches = document.getElementById("user-swatches");

var spectrumCanvas = document.getElementById("spectrum-canvas");
var spectrumCtx = spectrumCanvas.getContext("2d");
var spectrumCursor = document.getElementById("spectrum-cursor");
var spectrumRect = spectrumCanvas.getBoundingClientRect();

var hueCanvas = document.getElementById("hue-canvas");
var hueCtx = hueCanvas.getContext("2d");
var hueCursor = document.getElementById("hue-cursor");
var hueRect = hueCanvas.getBoundingClientRect();

var currentColor = "";
var hue = 0;
var saturation = 1;
var lightness = 0.5;

var rgbFields = document.getElementById("rgb-fields");
var hexField = document.getElementById("hex-field");

var red = document.getElementById("red");
var blue = document.getElementById("blue");
var green = document.getElementById("green");
var hex = document.getElementById("hex");

function ColorPicker() {
  this.addDefaultSwatches();
  createShadeSpectrum();
  createHueSpectrum();
}

ColorPicker.prototype.defaultSwatches = [
  "#FFFFFF",
  "#FFFB0D",
  "#0532FF",
  "#FF9300",
  "#00F91A",
  "#FF2700",
];

function createSwatch(target, color) {
  var swatch = document.createElement("button");
  swatch.classList.add("swatch");
  swatch.setAttribute("title", color);
  swatch.style.backgroundColor = color;
  swatch.addEventListener("click", function () {
    var color = tinycolor(this.style.backgroundColor);
    colorToPos(color);
    setColorValues(color);
  });
  target.appendChild(swatch);
  refreshElementRects();
}

ColorPicker.prototype.addDefaultSwatches = function () {
  for (var i = 0; i < this.defaultSwatches.length; ++i) {
    createSwatch(swatches, this.defaultSwatches[i]);
  }
};

function refreshElementRects() {
  spectrumRect = spectrumCanvas.getBoundingClientRect();
  hueRect = hueCanvas.getBoundingClientRect();
}

function createShadeSpectrum(color) {
  canvas = spectrumCanvas;
  ctx = spectrumCtx;
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  if (!color) color = "#f00";
  ctx.fillStyle = color;
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  var whiteGradient = ctx.createLinearGradient(0, 0, canvas.width, 0);
  whiteGradient.addColorStop(0, "#fff");
  whiteGradient.addColorStop(1, "transparent");
  ctx.fillStyle = whiteGradient;
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  var blackGradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
  blackGradient.addColorStop(0, "transparent");
  blackGradient.addColorStop(1, "#000");
  ctx.fillStyle = blackGradient;
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  canvas.addEventListener("mousedown", function (e) {
    startGetSpectrumColor(e);
  });
}

function createHueSpectrum() {
  var canvas = hueCanvas;
  var ctx = hueCtx;
  var hueGradient = ctx.createLinearGradient(0, 0, 0, canvas.height);
  hueGradient.addColorStop(0.0, "hsl(0, 100%, 50%)");
  hueGradient.addColorStop(0.17, "hsl(298.8, 100%, 50%)");
  hueGradient.addColorStop(0.33, "hsl(241.2, 100%, 50%)");
  hueGradient.addColorStop(0.5, "hsl(180, 100%, 50%)");
  hueGradient.addColorStop(0.67, "hsl(118.8, 100%, 50%)");
  hueGradient.addColorStop(0.83, "hsl(61.2, 100%, 50%)");
  hueGradient.addColorStop(1.0, "hsl(360, 100%, 50%)");
  ctx.fillStyle = hueGradient;
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  canvas.addEventListener("mousedown", function (e) {
    startGetHueColor(e);
  });
}

function colorToHue(color) {
  var color = tinycolor(color);
  var hueString = tinycolor("hsl " + color.toHsl().h + " 1 .5").toHslString();
  return hueString;
}

function colorToPos(color) {
  var color = tinycolor(color);
  var hsl = color.toHsl();
  hue = hsl.h;
  var hsv = color.toHsv();
  var x = spectrumRect.width * hsv.s;
  var y = spectrumRect.height * (1 - hsv.v);
  var hueY = hueRect.height - (hue / 360) * hueRect.height;
  updateSpectrumCursor(x, y);
  updateHueCursor(hueY);
  setCurrentColor(color);
  createShadeSpectrum(colorToHue(color));
}

function setColorValues(color) {
  var color = tinycolor(color);
  var rgbValues = color.toRgb();
  var hexValue = color.toHex();

  red.value = rgbValues.r;
  green.value = rgbValues.g;
  blue.value = rgbValues.b;
  hex.value = hexValue;

  $.post(
    "http://ffa/ffa:setCrosshairColor",
    JSON.stringify({
      Rcolor: red.value,
      Gcolor: green.value,
      Bcolor: blue.value,
    })
  );
}

function setCurrentColor(color) {
  color = tinycolor(color);
  currentColor = color;
  colorIndicator.style.backgroundColor = color;
  spectrumCursor.style.backgroundColor = color;
  hueCursor.style.backgroundColor = "hsl(" + color.toHsl().h + ",100%, 50%)";
}

function updateHueCursor(y) {
  hueCursor.style.top = y + "px";
}

function updateSpectrumCursor(x, y) {
  spectrumCursor.style.left = x + "px";
  spectrumCursor.style.top = y + "px";
}

var startGetSpectrumColor = function (e) {
  getSpectrumColor(e);
  spectrumCursor.classList.add("dragging");
  window.addEventListener("mousemove", getSpectrumColor);
  window.addEventListener("mouseup", endGetSpectrumColor);
};

function getSpectrumColor(e) {
  e.preventDefault();

  var x = e.pageX - spectrumRect.left;
  var y = e.pageY - spectrumRect.top;

  if (x > spectrumRect.width) {
    x = spectrumRect.width;
  }
  if (x < 0) {
    x = 0;
  }
  if (y > spectrumRect.height) {
    y = spectrumRect.height;
  }
  if (y < 0) {
    y = 0.1;
  }

  var xRatio = (x / spectrumRect.width) * 100;
  var yRatio = (y / spectrumRect.height) * 100;
  var hsvValue = 1 - yRatio / 100;
  var hsvSaturation = xRatio / 100;
  lightness = (hsvValue / 2) * (2 - hsvSaturation);
  saturation = (hsvValue * hsvSaturation) / (1 - Math.abs(2 * lightness - 1));
  var color = tinycolor("hsl " + hue + " " + saturation + " " + lightness);
  setCurrentColor(color);
  setColorValues(color);
  updateSpectrumCursor(x, y);
}

function endGetSpectrumColor(e) {
  spectrumCursor.classList.remove("dragging");
  window.removeEventListener("mousemove", getSpectrumColor);
}

function startGetHueColor(e) {
  getHueColor(e);
  hueCursor.classList.add("dragging");
  window.addEventListener("mousemove", getHueColor);
  window.addEventListener("mouseup", endGetHueColor);
}

function getHueColor(e) {
  e.preventDefault();
  var y = e.pageY - hueRect.top;
  if (y > hueRect.height) {
    y = hueRect.height;
  }
  if (y < 0) {
    y = 0;
  }
  var percent = y / hueRect.height;
  hue = 360 - 360 * percent;
  var hueColor = tinycolor("hsl " + hue + " 1 .5").toHslString();
  var color = tinycolor(
    "hsl " + hue + " " + saturation + " " + lightness
  ).toHslString();
  createShadeSpectrum(hueColor);
  updateHueCursor(y, hueColor);
  setCurrentColor(color);
  setColorValues(color);
}

function endGetHueColor(e) {
  hueCursor.classList.remove("dragging");
  window.removeEventListener("mousemove", getHueColor);
}

red.addEventListener("change", function () {
  var color = tinycolor(
    "rgb " + red.value + " " + green.value + " " + blue.value
  );
  colorToPos(color);
});

green.addEventListener("change", function () {
  var color = tinycolor(
    "rgb " + red.value + " " + green.value + " " + blue.value
  );
  colorToPos(color);
});

blue.addEventListener("change", function () {
  var color = tinycolor(
    "rgb " + red.value + " " + green.value + " " + blue.value
  );
  colorToPos(color);
});

modeToggle.addEventListener("click", function () {
  if (
    rgbFields.classList.contains("active")
      ? rgbFields.classList.remove("active")
      : rgbFields.classList.add("active")
  );
  if (
    hexField.classList.contains("active")
      ? hexField.classList.remove("active")
      : hexField.classList.add("active")
  );
});

window.addEventListener("resize", function () {
  refreshElementRects();
});

new ColorPicker();
