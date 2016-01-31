class Battle
{
  MonsterInstance enemy;
    
  String curBattleText;
  int textDepth;
  int index;
  int damage;
  int healed;
  boolean inSpell;
  char turn = 's';
  char menu = 'n';
  
  // s = starting state
  // e = enemy turn
  // p = player turn
  // q = player action
  // r = sub menu
  // f = enemy action
  // d = death
  // w = win

  String[] turnMenu = {"Attack","Magic","Run"};
  String[] magicMenu = {"Fire","Thunder","Heal"};
  int[] magicCosts = {3,8,5};
  
  float bSideBorder = sideBorder/2;
  float bTopBorder = topBorder/2;

  float mSideBorder = bSideBorder + sideBorder/8;
  float mTopBorder = bTopBorder + topBorder/8;
  
  float bMainMenuWidth = width-(bSideBorder*2);
  float bMainMenuHeight = height/3;
  
  Battle()
  {
    
  }
  
  Battle(MonsterInstance m,int ind)
  {
    enemy = m;
    index = ind;
    textDepth = 0;
    curBattleText = "";
    menuPoint = 0;
    inSpell = false;
  }
  
  void startBattle()
  {
    curBattleText = enemy.template.battleStartText;
    if(battleNext)
    {
      curBattleText = " ";
      battleNext = false;
      if(enemy.template.speed>p.speed)
      {
        turn = 'e';
      }
      else
      {
        turn = 'p';
      }
    }
  }

  void showBattleDetails()
  {
    background(255);
    fill(128);
    rect(bSideBorder,height-(height/3),width-(bSideBorder*2),height/3-bTopBorder);
    
    showOwnStats();
    showEnemyStats();
    
    text(turn,50,30);
    text(textDepth,70,30);
    text(menu,90,30);

    showBattleSprite();
    showBattleText();
    
    if(turn == 'p' && p.hp>0)
    {
      showMenu(turnMenu);
    }
  }
  
  void doBattle()
  {
    showBattleDetails();

    if(turn == 'd')
    {
      death();
    }
    else if(turn == 'w')
    {
      winBattle();
    }
    else
    {
      if(turn == 's')
      {
        startBattle();
      }
      else if(turn == 'p')
      {
         if(battleNext)
         {
            battleNext = false;
            if(menuPoint==1)
            {
                menu = 'm';
                turn = 'r';
            }
            else
            {
              turn = 'q';
            } 
         }
      }
      else if(turn == 'q')
      {
        if(menu == 'm')
        {
          if(magicCosts[menuPoint]>p.mp && !inSpell)
          {
            showMpCost(menuPoint);
            if(sequentialText("You don't have enough MP to cast " + magicMenu[menuPoint] + "!",0))
            {
              curBattleText = "";
              turn = 'r';
              menu = 'm';
            }
          }
          else
          {
            inSpell = true;
            doMagic(menuPoint);
          }
        }
        else
        {
          doSelected(menuPoint);
        }
      }
      else if(turn=='r')
      {
        if(key == 'q')
        {
          turn = 'p';
          menu = 'n';
        }
        
        if(menu=='m')
        {
           showMenu(magicMenu);
           showMpCost(menuPoint);
           if(battleNext)
           {
             turn = 'q';
             battleNext = false;
           }
        }
      }
      else if(turn=='e')
      {
        enemy.act();
      }  
    }
  }
   
  void nextTurn()
  {
    textDepth = 0;
    damage = 0;
    healed = 0;
    inSpell = false;
    curBattleText = "";
    menu = 'n';
    
    if(p.hp<1)
    {
      turn = 'd';
    }
    else if(enemy.hp<1)
    {
      turn = 'w';
    }
    else
    {
      if(turn == 'e' || turn == 'f')
      {
        turn = 'p';
      }
      if(turn == 'q')
      {
        turn = 'e';
      }
    }
  }
  
  void death()
  {
    if(textDepth==0)
    {
      sequentialText("You dead",1);
    }
    if(textDepth==1)
    {
      if(sequentialText("You black out",2))
      {
        mode = 'd';
        ent.remove(index);
      }
    }
  }
  
  void winBattle()
  {
      if(textDepth==0)
      {
        sequentialText("You win!!",1);
      }
      if(textDepth==1)
      {
        if(sequentialText("You gained "+ enemy.template.exp +" exp. points",2))
        {
          p.expToLvUp-=enemy.template.exp;
          
          if(p.expToLvUp<1)
          {
            textDepth = 3;
          }
        }
      }
      if(textDepth==2)
      {
        mode = 'o';
        ent.remove(index);
      }
      if(textDepth==3)
      {
          p.levelUp();
      }
  }
    
  void doSelected(int sel)
  {
    
    if(menuPoint==0)
    {
      basicAttack();
    }
    if(menuPoint==2)
    {
      run();
    }
  }
  
  void getHealed()
  {
     healed = 9 + (int)random(3);
     
     if(p.maxHp - p.hp < healed)
     {
       healed = p.maxHp - p.hp;
     }
     else if(p.maxHp == p.hp)
     {
       healed = 0;
     }
     
     p.hp+=healed;
  }
  
  void doMagic(int num)
  {
    if(textDepth==0)
    {
      animateMagic(num);
      if(sequentialText("You cast " + magicMenu[num] + "!",1))
      {
        if(num==2)
        {
          getHealed();
        }
        else
        {
          damage = getMagicDamage(num);
          damageEntity(enemy);
        }
        
        p.mp-=magicCosts[num];
      }
    }
    if(textDepth==1 && num!= 2)
    {
      if(sequentialText("You dealt " + damage + " damage!",2))
      {
        nextTurn();
      }
    }
    else if(textDepth==1 && healed == 0)
    {
      if(sequentialText("But you're already at full health?",2))
      {
        nextTurn();
      }
    }
    else if(textDepth==1)
    {
      if(sequentialText("You healed " + healed + " HP!",2))
      {
        nextTurn();
      }
    }
  }
  
  int getMagicDamage(int num)
  {
    if(num==0)
    {
      return (p.atk * 3)/enemy.template.def;
    }
    if(num==1)
    {
      return p.atk*4;
    }
    
    return 0;
  }
  
  void damageEntity(FightingEntity fe)
  {
     if(damage<1)
     {
       damage = 1;
     }
    
     if(damage>fe.hp)
     {
       fe.hp=0;
     }
     else
     {
       fe.hp-=damage;
     }
  }
  
  void animateMagic(int n)
  {
    if(n==0)
    {
      if((int)random(10)==5)
      {
        fill(255,0,0);
      }
      else
      {
        fill(255,128,0);
      }

      ellipse(width/2,height/2,sideBorder,sideBorder);
    }
    if(n==1)
    {
      if((int)random(10)==5)
      {
        fill(0);
      }
      else
      {
        fill(255,255,0);
      }
      rect(width/2-sideBorder/2,0,sideBorder,height);
    }
  }
  
  void useItem()
  {
    
  }
  
  void run()
  {
    if(textDepth == 0)
    {
      if(sequentialText("You ran away",1))
      {
        p.mercyInvincibility = 120;
        mode = 'o';
      }
    }
  }

  void basicAttack()
  {
    if(textDepth==0)
    {
       if(sequentialText(p.name + " attacks!",1))
       {
         damage = (p.atk/enemy.template.def);
         damageEntity(enemy);
       }
    }
    if(textDepth==1)
    {
      if(sequentialText("you dealt a crazy "+ damage +" damage!",2))
      {
        nextTurn();
      }
    }
  }
        
  boolean sequentialText(String s,int next)
  {
     curBattleText = s;      
    
     if(battleNext)
     {
       battleNext=false;
       textDepth = next;

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
     float mappedHP = map(p.hp,0,p.maxHp,0,width*0.36875);
     float mappedMP = map(p.mp,0,p.maxMp,0,width*0.36875);
     
     fill(128);
     rect(bSideBorder,topBorder/2,width/2.5,height/7);
     
     fill(0);
     text(p.name + " LV " + p.lv,sideBorder/2,topBorder/3);
     
     rect(mSideBorder,topBorder/2+topBorder/8,width*0.36875,height/21);
     fill(0,255,0);
     rect(mSideBorder,topBorder/2+topBorder/8,mappedHP,height/21);
     fill(0);
     rect(mSideBorder,topBorder/2+topBorder/4+height/21,width*0.36875,height/21);
     fill(0,0,255);
     rect(mSideBorder,topBorder/2+topBorder/4+height/21,mappedMP,height/21);
  }
  
  void showEnemyStats()
  {
     float mappedHP = map(enemy.hp,0,enemy.template.hp,0,width*0.36875);

     fill(128);
     rect(width-sideBorder/2-width/2.5,topBorder/2,width/2.5,height/7);
     
     fill(0);
     text(enemy.template.name,width-sideBorder/2-width/2.5,topBorder/3);
     
     rect(width-sideBorder/2-width/2.5+sideBorder/8,topBorder/2+topBorder/8,width*0.36875,height/21);
     fill(0,255,0);
     rect(width-sideBorder/2-width/2.5+sideBorder/8,topBorder/2+topBorder/8,mappedHP,height/21);
  }
  
  void showMenu(String[] points)
  {
    int l = points.length;
    
    if(menuPoint>l-1)
    {
      menuPoint=0;
    }
    if(menuPoint<0)
    {
      menuPoint=l-1;
    }
    
    fill(255);
    rect(mSideBorder,height-(height/3)+topBorder/8,width/3,height/3-topBorder/2-topBorder/4);

    fill(0);
    
    for(int i=0;i<l;i++)
    {
      text(points[i],sideBorder/2+sideBorder/3,height-(height/3)+topBorder/2-topBorder/10+(i*topBorder*0.36)+(topBorder*0.1));
    }
      
    ellipse(sideBorder/2-sideBorder/10+sideBorder/3,height-(height/3)+topBorder/2-topBorder/10+(menuPoint*topBorder*0.36),10,10);
    
  }
  
  void showBattleSprite()
  {
    image(enemy.template.battleSprite,width/2,height/2);
  }
  
  void showMpCost(int num)
  {
     float mappedMP = map(p.mp,0,p.maxMp,0,width*0.36875);
     float mappedCost = map(magicCosts[num],0,p.maxMp,0,width*0.36875);
     
     if(magicCosts[num]>p.mp)
     {
       fill(86,86,86);
       rect(mSideBorder,topBorder/2+topBorder/4+height/21,mappedMP,height/21);
     }
     else
     {    
       fill(255,0,0);
       rect(mSideBorder+mappedMP-mappedCost,topBorder/2+topBorder/4+height/21,mappedCost,height/21);
     }
  }

}
