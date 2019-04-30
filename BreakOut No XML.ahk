#SingleInstance,Force
SetBatchLines,-1
SetWinDelay -1
Width:=800,Height:=500
global BB:=new BreakOut(Width,Height,25,20,100,30,5,3),ID
BB.Zen:=0
SetTimer,Tick,10
return
F1::
SetTimer,Tick,Off
return
F2::
SetTimer,Tick,10
return
GuiEscape:
GuiClose:
ExitApp
return
Tick(){
	if(((Left:=GetKeyState("Left","P"))||(Right:=GetKeyState("Right","P"))))
		New:=BB.PlayerX+(Left?-6:6),New:=New<0?0:New+BB.PlayerWidth>BB.Width?BB.Width-BB.PlayerWidth:New,BB.PlayerX:=New,BB.PlayerObj.SetAttribute("x",BB.PlayerX),Left:=Right:="",BB.Moved:=1
	for a,b in BB.Balls{
		b.x+=b.hx*b.Speed,b.y+=b.hy*b.Speed,w:=BB.BrickWidth,h:=BB.BrickHeight
		if(BB.Width<=b.x+b.r)
			b.hx:=b.hx*-1,b.x:=BB.Width-b.r
		else if(b.x-b.r<=0)
			b.hx:=b.hx*-1,b.x:=b.r
		if(BB.Height<=b.y+b.r){
			(BB.Zen?(b.hy:=b.hy*-1,b.y:=BB.Height-b.r):(BB.Balls.Remove(a),b.Obj.ParentNode.RemoveChild(b.Obj)))
		}else if(b.y-b.r<=0)
			b.hy:=b.hy*-1,b.y:=b.r
		b.Obj.SetAttribute("cx",b.x),b.Obj.SetAttribute("cy",b.y),Side:=b.hx<0?b.x-b.r:b.x+b.r,Top:=b.hy<0?b.y-b.r:b.y+b.r,RemX:=Floor(Side-Mod(Side,w)),RemY:=Floor(Top-Mod(Top,h))
		if(IsObject(Brick:=(Remove:=BB.Bricks["x" RemX])["y" RemY])){
			for c,d in [[b.hy,"y","h","x","w"],[b.hx,"x","w","y","h"]]{
				Face:=Brick[d.2]+(d.1<0?Brick[d.3]:0),Ball:=d.1<=0?(b[d.2]-b.r):(b[d.2]+b.r)
				if(Face+5>=Ball&&Face-5<=Ball)
					BallPos:=(d.1<0?(b[d.4]+b.r):(b[d.4]-b.r)),Brick.Obj.ParentNode.RemoveChild(Brick.Obj),(d.2="y")?(b.hy:=b.hy*-1):(b.hx:=b.hx*-1),BB.Bricks["x" RemX].Remove("y" RemY)
		}}if(b.x>=BB.PlayerX&&b.x<=BB.PlayerX+BB.PlayerWidth&&b.y+b.r>=BB.Height-20)
			PX:=BB.PlayerX,PW:=BB.PlayerWidth,Pos:=b.x-PX-(PW/2),Half:=PX+PW/2,b.hy:=-(New:=(1+(.4-1)*((Abs(Pos)-1)/(Floor(PW)-1)))),b.hx:=((2-Abs(b.hy))*(b.x<Half?-1:1))
	}if(!Count:=BB.BricksSVG.GetElementsByTagName("rect").Length){
		for a,b in BB.Balls
			b.Obj.ParentNode.RemoveChild(b.Obj)
		return Display(BB.Moved=0?"Sometimes the best way to play is to not play at all":BB.Zen?"Well done my friend.":"Well done you!",BB.Moved?1500:5000),New()
	}if(!BB.Balls.MinIndex()){
		if(BB.Lives>0){
			BB.Lives-=1,Display(BB.Lives>0?BB.Lives (BB.Lives>1?" Lives ":" Life ") " Remaining":"Last Life, Make it count!")
			while(BB.BallCount>=A_Index){
				if(1)
					Random,x,20,% BB.Width-20
				else
					x:=200
				BB.AddBall(x,BB.Height-30,5,(!Mod(A_Index,2)?-1:1),-1,3)
			}
		}else
			Display("Game Over"),New()
	}
	Balls:=BB.BallSVG.GetElementsByTagName("circle").Length
	if(Balls!=Count){
		WinSetTitle,%ID%,,% "AHK Breakout - Remaining Bricks: " Count " Balls: " Balls
		Balls:=Count
	}
}
FixIE(Version=0){
	static Key:="Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION",Versions:={7:7000,8:8888,9:9999,10:10001,11:11001}
	Version:=Versions[Version]?Versions[Version]:Version
	if(A_IsCompiled)
		ExeName:=A_ScriptName
	else
		SplitPath,A_AhkPath,ExeName
	RegRead,PreviousValue,HKCU,%Key%,%ExeName%
	if(!Version)
		RegDelete,HKCU,%Key%,%ExeName%
	else
		RegWrite,REG_DWORD,HKCU,%Key%,%ExeName%,%Version%
	return PreviousValue
}
Class BreakOut{
	__New(Width,Height,BrickWidth:=25,BrickHeight:=20,BallCount:=1,BrickRows:=10,BallRadius:=5,Lives:=3,PlayerWidth:=100){
		static wb,Init
		Height:=Height<A_ScreenHeight-100?Height:A_ScreenHeight-100,Width:=Width<=A_ScreenWidth-100?Width:A_ScreenWidth-100,Width-=Mod(Width,BrickWidth),Height-=Mod(Height,BrickHeight),BrickRows:=BrickRows*BrickHeight>=Height-20?Floor((Height-20)/BrickHeight):BrickRows,this.Bricks:=[],this.Balls:=[],this.Width:=Width,this.Height:=Height,this.Lives:=Lives,TotalWidth:=Width/BrickWidth,TotalHeight:=BrickRows,Max:=650,TotalBricks:=0,this.Moved:=0
		if(TotalWidth*TotalHeight>Max){
			while(TotalBricks<Max){
				TotalBricks+=Width/BrickWidth,BrickRows:=A_Index
				if(TotalBricks+Width/BrickWidth>Max)
					Break
		}}if(!Init){
			Ver:=FixIE(11),Init:=1
			Gui,+hwndMain
			Gui,Add,ActiveX,% "vwb w" Width " h" Height,mshtml
			FixIE(Ver),ID:="ahk_id" Main
			Gui,Show
		}wb.Navigate("about:<html><script>onerror=function(event){return true;};onmessage=function(event){return false;};onclick=function(event){ahk_event('OnClick',event);};onchange=function(event){ahk_event('OnChange',event);};oninput=function(event){ahk_event('OnInput',event);};onprogresschange=function(event){ahk_event('OnProgressChange',event);};</script><body style='background-color:Black;margin:0px;'><div id='Settings' Style='Visibility:Shown'></div><svg><svg/><svg/><svg/></svg></body></html>")
		while(wb.ReadyState!=4)
			Sleep,10
		this.wb:=wb,x:=0,y:=0,this.BallCount:=BallCount,Board:=wb.Document.GetElementsByTagName("svg"),this.BallSVG:=Board.Item[1],this.BricksSVG:=Board.Item[2],this.PlayerSVG:=Board.Item[3],this.BrickWidth:=BrickWidth,this.BrickHeight:=BrickHeight,this.BrickRows:=BrickRows
		while(A_Index<=BrickRows){
			while(x<this.Width){
				if(!Mod(A_Index,3)||1)
					this.AddBrick(x,y,BrickWidth,BrickHeight,"")
				x+=BrickWidth
			}y+=BrickHeight,x:=0
		}while(A_Index<=BallCount){
			if(1){
				Random,RandomX,0,%Width%
				Random,RandomY,% Height-BrickHeight+BallRadius,Height-BallRadius
			}else
				RandomX:=240,RandomY:=Height-20
			this.AddBall(RandomX,RandomY,BallRadius,!Mod(A_Index,2)?-1:1,-1,3)
		}this.PlayerObj:=this.AddBrick((PlayerX:=Floor((Width/2)-(PlayerWidth/2))),Height-20,PlayerWidth,20,"Grey","Purple",0),this.PlayerX:=PlayerX,this.PlayerWidth:=PlayerWidth
		return this
	}AddBall(x,y,r,hx,hy,speed){
		New:=this.CreateElement("circle",this.BallSVG),this.Balls.Push({x:x,y:y,r:r,hx:hx,hy:hy,speed:speed,obj:New})
		for a,b in {cx:x,cy:y,r:r,fill:"Purple"}
			New.SetAttribute(a,b)
		return New
	}AddBrick(x,y,w,h,stroke:="Grey",fill:="Purple",AddObj:=1){
		New:=this.CreateElement("rect",(AddObj?this.BricksSVG:this.PlayerSVG)),(AddObj?this.Bricks["x" x,"y" y]:={x:x,y:y,w:w,h:h,Obj:New}:"")
		for a,b in Brick:={x:x+1,y:y+1,width:w-1,height:h-1,fill:fill,stroke:Stroke}
			New.SetAttribute(a,b)
		return New
	}CreateElement(Type,Parent){
		return Parent.AppendChild(Item:=this.wb.Document.CreateElementNS("http://www.w3.org/2000/svg",Type))
	}
}
Display(Message,Time:=1000){
	Parent:=BB.wb.Document.GetElementsByTagName("svg").Item[0]
	Parent.AppendChild(Text:=BB.wb.Document.CreateElementNS("http://www.w3.org/2000/svg","text"))
	for a,b in {"font-size":BB.Width/StrLen(Message),fill:"Purple","font-weight":900,stroke:"White",width:"Auto",height:"Auto","font-family":"Verdana",x:"50%","word-wrap":"Auto",y:"60%","text-anchor":"middle","alignment-baseline":"middle"}
		Text.SetAttribute(a,b)
	Text.InnerText:=Message
	Sleep,%Time%
	Text.ParentNode.RemoveChild(Text)
}
New(){
	Zen:=BB.Zen,BB:=new BreakOut(BB.Width,BB.Height,BB.BrickWidth,BB.BrickHeight,BB.BallCount,BB.BrickRows),BB.Zen:=Zen
}