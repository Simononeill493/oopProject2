class Battle
{
  MonsterInstance enemy;
    
  String curBattleText;
  char[] buffer;
  int phase;
  int textDepth;
  int index;
  int damage;
  char turn = 's';
  
// s = starting state
// e = enemy turn
// p = player turn
// q = player action
// f = enemy action
  Battle(MonsterInstance m,int ind)
  {
    enemy = m;
    index = ind;
    phase = 1;
    textDepth = 0;
    buffer = "#".toCharArray();
    menuPoint = 0;
  }
  
  void doBattle()
  {       
      if(turn == 's')
      {
        battleText(enemy.template.battleStartText);
        if(next)
        {
          curBattleText = " ";
          next = false;
          if(enemy.template.speed>((Player)(ent.get(0))).speed)
          {
            turn = 'e';
          }
          else
          {
            turn = 'p';
          }
        }
      }
      
     if(turn == 'p')
     {
       if(next)
       {
          next = false;
          turn = 'q';
       }
     }
     
     if(turn == 'q')
     {
       {
         doSelected(menuPoint);
       }
     }
         
    if(turn == 'w')
    {
      if(textDepth==0)
      {
        sequentialText("You win!!");
      }
      if(textDepth==1)
      {
        if(sequentialText("You gained "+ enemy.template.exp +" exp. points"))
        {
          mode = 'o';
          ent.remove(index);
        }
      }
    }
    
    showBattleDetails();
  }
      
    
  void doSelected(int sel)
  {
    
    if(menuPoint==0)
    {
      basicAttack();
    }
    if(menuPoint==1)
    {
      println("Magic");
    }
    if(menuPoint==2)
    {
      println("item");
    }
    if(menuPoint==3)
    {
      println("run");
    }
  }
  
  void basicAttack()
  {
    if(textDepth==0)
    {
       if(sequentialText(((Player)(ent.get(0))).name + " attacks!"))
       {
         damage = (((Player)(ent.get(0))).atk/enemy.template.def);
         if(damage<1)
         {
           damage=1;
         }
         if(damage>enemy.curHp)
         {
           enemy.curHp=0;
         }
         else
         {
           enemy.curHp-=damage;
         }
       }
    }
    if(textDepth==1)
    {
      sequentialText("you dealt a crazy "+ damage +" damage!");
    }
    if(textDepth==2)
    {
      if(enemy.curHp==0)
      {
        sequentialText("You know he ded");
        turn = 'w';
        textDepth = 0;
      }
      else
      {
        turn = 'e';
        textDepth = 0;
      }
    }
  }
  
  void showTurnMenu()
  {
    if(menuPoint>3)
    {
      menuPoint=0;
    }
    if(menuPoint<0)
    {
      menuPoint=3;
    }
    
    fill(255);
    rect(sideBorder/2+sideBorder/8,height-(height/3)+topBorder/8,width/3,height/3-topBorder/2-topBorder/4);
    fill(0);
    text("Attack\nMagic\nItem\nRun",sideBorder/2+sideBorder/3,height-(height/3)+topBorder/2);
    ellipse(sideBorder/2-sideBorder/10+sideBorder/3,height-(height/3)+topBorder/2-topBorder/10+(menuPoint*topBorder*0.36),10,10);
  }
    
  void battleText(String s)
  {
      curBattleText = s;
  }
  
  boolean sequentialText(String s)
  {
     battleText(s);
     
     if(next)
     {
       next=false;
       textDepth++;
       
       return true;
     }
     
     return false;
  }
  
  void showBattleText()
  {    
     fill(0);
     text(curBattleText,sideBorder,height-(height/3)+topBorder/2);
  }
  
  void showOwnStats()
  {
     float mappedHP = map((((Player)(ent.get(0))).hp),0,(((Player)(ent.get(0))).maxHp),0,width*0.36875);
     float mappedMP = map((((Player)(ent.get(0))).mp),0,(((Player)(ent.get(0))).maxMp),0,width*0.36875);
     
     fill(128);
     rect(sideBorder/2,topBorder/2,width/2.5,height/7);
     
     fill(0);
     text((((Player)(ent.get(0))).name) + " LV " + (((Player)(ent.get(0))).lv),sideBorder/2,topBorder/3);
     
     rect(sideBorder/2+sideBorder/8,topBorder/2+topBorder/8,width*0.36875,height/21);
     fill(0,255,0);
     rect(sideBorder/2+sideBorder/8,topBorder/2+topBorder/8,mappedHP,height/21);
     fill(0);
     rect(sideBorder/2+sideBorder/8,topBorder/2+topBorder/4+height/21,width*0.36875,height/21);
     fill(0,0,255);
     rect(sideBorder/2+sideBorder/8,topBorder/2+topBorder/4+height/21,mappedMP,height/21);
  }
  
  void showEnemyStats()
  {
     float mappedHP = map(enemy.curHp,0,enemy.template.hp,0,width*0.36875);

     fill(128);
     rect(width-sideBorder/2-width/2.5,topBorder/2,width/2.5,height/7);
     
     fill(0);
     text(enemy.template.name,width-sideBorder/2-width/2.5,topBorder/3);
     
     rect(width-sideBorder/2-width/2.5+sideBorder/8,topBorder/2+topBorder/8,width*0.36875,height/21);
     fill(0,255,0);
     rect(width-sideBorder/2-width/2.5+sideBorder/8,topBorder/2+topBorder/8,mappedHP,height/21);
  }
  
  void showBattleDetails()
  {
    background(255);
    fill(128);
    rect(sideBorder/2,height-(height/3),width-(sideBorder),height/3-topBorder/2);
    
    showOwnStats();
    showEnemyStats();
    
    text(phase,30,30);
    text(turn,50,30);
    
    showBattleSprite();
    showBattleText();
    
    if(turn == 'p')
    {
      showTurnMenu();
    }
  }
  
  void showBattleSprite()
  {
    image(enemy.template.battleSprite,width/2,height/2);
  }

}
