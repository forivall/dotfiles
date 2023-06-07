let url = 'https://xkcd.com/info.0.json';
let req = new Request(url);
let json = await req.loadJSON();
let imgURL = json['img'];
let alt = json['alt'];
req = new Request(imgURL);
let img = await req.loadImage();

// QuickLook.present(img);
// if (config.runsWithSiri) {
//   Speech.speak(alt)
// }

let weburl = `https://xkcd.com/${json['num'] || ''}`
let w = new ListWidget();
w.url = weburl;
w.spacing = 0;
w.setPadding(0, 8, 3, 8);
let title = w.addText(json.title);
title.centerAlignText();
title.font = Font.caption1();
title.lineLimit = 1;
let imgw = w.addImage(img);
imgw.url = weburl;
imgw.centerAlignImage();
let t = w.addText(alt);
t.font = Font.caption1();
t.lineLimit = 4;
Script.setWidget(w);

Script.complete();
