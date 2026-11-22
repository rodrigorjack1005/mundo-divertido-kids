import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

void main()=>runApp(const MaterialApp(debugShowCheckedModeBanner:false,home:KidsGame()));
class KidsGame extends StatefulWidget{const KidsGame({super.key});@override State<KidsGame> createState()=>_KidsGameState();}
class _KidsGameState extends State<KidsGame> with SingleTickerProviderStateMixin{
 late final Ticker ticker; Duration last=Duration.zero;
 final AudioPlayer musicPlayer=AudioPlayer(); final AudioPlayer sfxPlayer=AudioPlayer(); bool soundOn=true;
 Future<void> playSfx(String file) async {if(!soundOn)return; try{await sfxPlayer.stop(); await sfxPlayer.play(AssetSource('audio/$file'));}catch(_){}}
 Future<void> toggleMusic() async {setState(()=>soundOn=!soundOn); if(soundOn){try{await musicPlayer.resume();}catch(_){await musicPlayer.play(AssetSource('audio/music_kids.wav'));}}else{await musicPlayer.pause();}}
 String page='menu',hero='Romeu'; int world=0,level=0,coins=0,lives=3;
 double x=.2,y=0,v=0,cam=0; bool left=false,right=false,paused=false,shield=false;
 final Set<int> got={};
 final worlds=[
  {'name':'Norte - Amazônia','emoji':'🌳','color':Color(0xff13864a),'desc':'Rios, árvores gigantes e animais da floresta'},
  {'name':'Nordeste - Sertão','emoji':'🌵','color':Color(0xffd89b36),'desc':'Cactos, dunas e vilas coloridas'},
  {'name':'Centro-Oeste - Pantanal','emoji':'🐊','color':Color(0xff3c9c83),'desc':'Lagoas, pássaros e campos alagados'},
  {'name':'Sudeste - Montanhas','emoji':'⛰️','color':Color(0xff4c83c5),'desc':'Montanhas, cidades e trilhas'},
  {'name':'Sul - Araucárias','emoji':'🌲','color':Color(0xff458d69),'desc':'Florestas, campos e clima frio'},
  {'name':'Goiânia - Castelo Final','emoji':'🏰','color':Color(0xffa56ac7),'desc':'A grande aventura final em Goiás'},
 ];
 final List<double> coinX=List.generate(24,(i)=>.65+i*.39);
 final List<double> enemyX=[1.9,3.7,5.5,7.4,8.8];
 @override void initState(){super.initState();ticker=createTicker(tick)..start(); _startMusic();}
 Future<void> _startMusic() async {try{await musicPlayer.setReleaseMode(ReleaseMode.loop);await musicPlayer.setVolume(.28);await musicPlayer.play(AssetSource('audio/music_kids.wav'));}catch(_){}}
 @override void dispose(){ticker.dispose();musicPlayer.dispose();sfxPlayer.dispose();super.dispose();}
 void tick(Duration t){if(page!='game'||paused){last=t;return;}final dt=last==Duration.zero?.016:((t-last).inMicroseconds/1e6).clamp(0.0,.04).toDouble();last=t;setState((){
 if(left)x-=1.55*dt;if(right)x+=1.55*dt;x=x.clamp(0.0,10.0).toDouble();
 if(y>0||v>0){v-=3.1*dt;y+=v*dt;if(y<=0){y=0;v=0;}}
 cam=math.max(0,x-.7);
 for(int i=0;i<coinX.length;i++){if(!got.contains(i)&&(coinX[i]-x).abs()<.23&&y<.55){got.add(i);coins++;playSfx('coin.wav');}}
 for(final e in enemyX){if((e-x).abs()<.22&&y<.24&&!shield){lives--;playSfx('hit.wav');x=math.max(0,x-.55);if(lives<=0)page='over';break;}}
 if(x>=9.6){page='levelwon';playSfx('win.wav');}
 });}
 void startLevel(int w,int l){setState((){world=w;level=l;page='game';x=.2;y=0;v=0;cam=0;coins=0;lives=3;got.clear();paused=false;shield=false;});}
 Widget action(String text,VoidCallback fn)=>ElevatedButton(onPressed:(){playSfx('click.wav');fn();},style:ElevatedButton.styleFrom(backgroundColor:Colors.amber,foregroundColor:Colors.brown,padding:const EdgeInsets.symmetric(horizontal:26,vertical:15)),child:Text(text,style:const TextStyle(fontWeight:FontWeight.w900)));
 @override Widget build(BuildContext c)=>Scaffold(body:Container(decoration:const BoxDecoration(gradient:LinearGradient(colors:[Color(0xff087c50),Color(0xff71d65b)],begin:Alignment.topCenter,end:Alignment.bottomCenter)),child:SafeArea(child:page=='menu'?menu():page=='heroes'?heroes():page=='map'?map():page=='levels'?levels():page=='game'?game():page=='levelwon'?levelWon():result())));
 Widget menu()=>Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Text('🇧🇷',style:TextStyle(fontSize:55)),const Text('MUNDO DIVERTIDO KIDS',textAlign:TextAlign.center,style:TextStyle(color:Colors.white,fontSize:29,fontWeight:FontWeight.w900)),const Text('Uma aventura por todo o Brasil!',style:TextStyle(color:Colors.white)),const SizedBox(height:26),action('JOGAR',()=>setState(()=>page='heroes')),const SizedBox(height:8),TextButton.icon(onPressed:toggleMusic,icon:Icon(soundOn?Icons.volume_up:Icons.volume_off,color:Colors.white),label:Text(soundOn?'SOM LIGADO':'SOM DESLIGADO',style:const TextStyle(color:Colors.white))),const SizedBox(height:12),const Text('Protótipo jogável • 6 mundos • 3 fases por mundo',style:TextStyle(color:Colors.white70))]));
 Widget heroes()=>Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Text('QUEM VAI AVENTURAR?',style:TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:22)),const SizedBox(height:20),Wrap(spacing:16,children:[heroCard('Romeu','🧢','Super Salto',Colors.blue),heroCard('Sara','🎀','Escudo Mágico',Colors.pink)]),TextButton(onPressed:()=>setState(()=>page='menu'),child:const Text('Voltar',style:TextStyle(color:Colors.white)))]));
 Widget heroCard(String n,String em,String power,Color color)=>InkWell(onTap:()=>setState((){hero=n;page='map';}),child:Container(width:145,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),border:Border.all(color:color,width:4)),child:Column(children:[Text(em,style:const TextStyle(fontSize:56)),Text(n,style:TextStyle(fontSize:23,color:color,fontWeight:FontWeight.bold)),Text(power),const Text('ESCOLHER')]))));
 Widget map()=>Column(children:[const SizedBox(height:12),Text('MAPA DO BRASIL • $hero',style:const TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w900)),const Padding(padding:EdgeInsets.all(8),child:Text('Escolha qualquer região para jogar',style:TextStyle(color:Colors.white))),Expanded(child:ListView.builder(padding:const EdgeInsets.all(12),itemCount:worlds.length,itemBuilder:(c,i){final w=worlds[i];return Card(child:ListTile(leading:Text(w['emoji'] as String,style:const TextStyle(fontSize:32)),title:Text(w['name'] as String,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text(w['desc'] as String),trailing:const Icon(Icons.play_circle_fill),onTap:()=>setState(()=>{world=i,page='levels'})));})),TextButton(onPressed:()=>setState(()=>page='heroes'),child:const Text('Trocar personagem',style:TextStyle(color:Colors.white)))]);
 Widget levels()=>Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Text(worlds[world]['name'] as String,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.bold)),const Text('Escolha uma fase',style:TextStyle(color:Colors.white)),const SizedBox(height:20),Wrap(spacing:12,children:List.generate(3,(i)=>action('FASE ${i+1}',()=>startLevel(world,i)))),const SizedBox(height:15),action('VOLTAR AO MAPA',()=>setState(()=>page='map'))]));
 Widget game()=>Column(children:[Padding(padding:const EdgeInsets.all(6),child:Row(children:[Text('$hero ♥ $lives',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)),const Spacer(),Text('🪙 $coins',style:const TextStyle(color:Colors.white,fontSize:18)),IconButton(onPressed:toggleMusic,icon:Icon(soundOn?Icons.volume_up:Icons.volume_off,color:Colors.white)),IconButton(onPressed:()=>setState(()=>paused=!paused),icon:Icon(paused?Icons.play_arrow:Icons.pause,color:Colors.white))])),Expanded(child:GestureDetector(onTapDown:(d){if(d.localPosition.dx>MediaQuery.of(context).size.width*.72)jump();},child:CustomPaint(painter:WorldPainter(hero,x,cam,y,coinX,got,enemyX,shield,world),child:const SizedBox.expand()))),if(paused)const Text('JOGO PAUSADO',style:TextStyle(color:Colors.white)),Padding(padding:const EdgeInsets.all(10),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[control(Icons.arrow_left,()=>left=true,()=>left=false),control(Icons.arrow_right,()=>right=true,()=>right=false),control(Icons.arrow_upward,jump,()=>{}),if(hero=='Sara')control(Icons.shield,()=>setState(()=>shield=true),()=>setState(()=>shield=false))]))]);
 Widget control(IconData i,VoidCallback down,VoidCallback up)=>GestureDetector(onTap:down,onLongPress:down,onLongPressUp:up,child:Container(width:58,height:54,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Icon(i,color:Colors.green,size:31)));
 void jump(){if(page=='game'&&!paused&&y==0){playSfx('jump.wav');setState(()=>v=hero=='Romeu'?2.7:2.15);}}
 Widget levelWon()=>Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Text('FASE CONCLUÍDA! ⭐',style:TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.w900)),Text('Você coletou $coins moedas!',style:const TextStyle(color:Colors.white,fontSize:19)),const SizedBox(height:18),action('PRÓXIMA FASE',()=>startLevel(world,(level+1)%3)),action('VOLTAR AOS MAPAS',()=>setState(()=>page='map'))]));
 Widget result()=>Center(child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Text('SUAS VIDAS ACABARAM',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.bold)),Text('Moedas: $coins',style:const TextStyle(color:Colors.white,fontSize:20)),action('TENTAR NOVAMENTE',()=>startLevel(world,level)),TextButton(onPressed:()=>setState(()=>page='map'),child:const Text('Voltar ao mapa',style:TextStyle(color:Colors.white)))]));
}
class WorldPainter extends CustomPainter{
 final String hero;final double x,cam,y;final List<double> coins,enemies;final Set<int> got;final bool shield;final int world;
 WorldPainter(this.hero,this.x,this.cam,this.y,this.coins,this.got,this.enemies,this.shield,this.world);
 @override void paint(Canvas c,Size s){final palettes=[[Color(0xff70dfff),Color(0xffd8faff)],[Color(0xffffd17b),Color(0xffffefc3)],[Color(0xff77d9c0),Color(0xffd7fff0)],[Color(0xff8fc7ff),Color(0xffe9f5ff)],[Color(0xffb7e5ff),Color(0xfff2fbff)],[Color(0xffd7b5ff),Color(0xffffe5fa)]];final colors=palettes[world];c.drawRect(Offset.zero&s,Paint()..shader=LinearGradient(colors:colors).createShader(Offset.zero&s));
 for(int i=0;i<13;i++){final xx=i*100.0-(cam*65)%100;final green=[Color(0xff168d4b),Color(0xffa6a13a),Color(0xff258c74),Color(0xff398d65),Color(0xff347d54),Color(0xff8c60b2)][world];c.drawCircle(Offset(xx,s.height*.3),38,Paint()..color=green);c.drawRect(Rect.fromLTWH(xx-7,s.height*.3,14,s.height*.5),Paint()..color=const Color(0xff79502d));}
 c.drawRect(Rect.fromLTWH(0,s.height*.78,s.width,s.height*.22),Paint()..color=world==1?const Color(0xffc58c42):const Color(0xff79502d));c.drawRect(Rect.fromLTWH(0,s.height*.75,s.width,12),Paint()..color=const Color(0xff64d84b));
 for(int i=0;i<coins.length;i++){final xx=(coins[i]-cam)*s.width*.55;if(!got.contains(i)&&xx>-20&&xx<s.width+20)c.drawCircle(Offset(xx,s.height*.65),11,Paint()..color=const Color(0xffffd22e));}
 for(final e in enemies){final xx=(e-cam)*s.width*.55;if(xx>-20&&xx<s.width+20)c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(xx-14,s.height*.7,28,24),const Radius.circular(10)),Paint()..color=const Color(0xffa64b25));}
 final px=(x-cam)*s.width*.55,py=s.height*.75-y*s.height*.22;if(shield&&hero=='Sara')c.drawCircle(Offset(px,py-30),35,Paint()..color=Colors.pink.withOpacity(.3));c.drawCircle(Offset(px,py-48),16,Paint()..color=const Color(0xffffc99c));c.drawCircle(Offset(px,py-59),17,Paint()..color=const Color(0xff704326));c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(px-17,py-34,34,37),const Radius.circular(8)),Paint()..color=hero=='Romeu'?Colors.blue:Colors.pink);c.drawRect(Rect.fromLTWH(px-14,py+3,11,14),Paint()..color=Colors.white);c.drawRect(Rect.fromLTWH(px+3,py+3,11,14),Paint()..color=Colors.white);
 }
 @override bool shouldRepaint(covariant WorldPainter old)=>true;
}
