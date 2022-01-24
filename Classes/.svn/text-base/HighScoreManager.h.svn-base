/*
 * This file is Copyright (C) 2011 by Syniad Software Ltd.
 * All rights reserved.
 *
 * The contents of this file are subject to the Syniad Software Ltd. license agreement.
 * You may not use this file except in compliance with the license.
 *
 */

#import <vector>
#import <string>

#import "IPersister.h"

using namespace std;

template <typename T> class HighScoreManager
{
private:
  vector<T> m_Scores;
  IPersister* m_Persister;
  int m_TableSize;
  
  HighScoreManager();
  int CheckHighScore(T score, bool insert);
  
public:
  HighScoreManager(IPersister* persister, int tableSize);
  
  int IsHighScore(T score);
  int InsertHighScore(T score);
  
  vector<T>& GetScores();
};

template <typename T> HighScoreManager<T>::HighScoreManager(IPersister* persister, int tableSize)
{
  m_Persister = persister;
  m_TableSize = tableSize;
  
  m_Persister->Open(PersisterModeRead);
  
  string data;
  while (m_Persister->ReadLine(data))
  {
    m_Scores.push_back(T(data));
  }
  
  m_Persister->Close();
}

template <typename T> int HighScoreManager<T>::CheckHighScore(T score, bool insert)
{
  if (score == 0)
    return 0;
  
  typename vector<T>::iterator iter = m_Scores.begin();
 
  int pos = 0;
  bool wouldInsert = FALSE;
  for (; iter != m_Scores.end(); ++iter)
  {
    pos++;
    if (score > *iter)
    {
      wouldInsert = TRUE;
      if (insert)
        m_Scores.insert(iter, score);
      break;
    }
  }
  if (m_Scores.size() < m_TableSize && ! wouldInsert)
  {
    if (insert)
    {
      m_Scores.push_back(score);
    }
    return pos + 1;
  }
  
  if (m_Scores.size() > m_TableSize)
    m_Scores.erase(m_Scores.end());

  return ! wouldInsert ? FALSE : pos;
}

template <typename T> int HighScoreManager<T>::IsHighScore(T score)
{
  return CheckHighScore(score, FALSE);
}

template <typename T> int HighScoreManager<T>::InsertHighScore(T score)
{
  int inserted = CheckHighScore(score, TRUE);
  
  if (inserted)
  {
    m_Persister->Open(PersisterModeWrite);

    typename vector<T>::iterator iter = m_Scores.begin();
    for (; iter != m_Scores.end(); ++iter)
    {
      m_Persister->WriteLine(iter->Serialise());
    }

    m_Persister->Close();
  }
  
  return inserted;
}

template <typename T> vector<T>& HighScoreManager<T>::GetScores()
{
  return m_Scores;
}
