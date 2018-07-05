//
//  GoalsLocalManager.swift
//  Modacity
//
//  Created by BC Engineer on 6/7/18.
//  Copyright © 2018 crossover. All rights reserved.
//

import UIKit

class GoalsLocalManager: NSObject {
    static let manager = GoalsLocalManager()
    
    func loadGoals() -> [Note]? {
        if let goalIds = UserDefaults.standard.object(forKey: "goal_ids") as? [String] {
            var goals = [Note]()
            for goalId in goalIds {
                if let json = UserDefaults.standard.object(forKey: "goal_\(goalId)") as? [String:Any] {
                    if let goal = Note(JSON: json) {
                        goals.append(goal)
                    }
                }
            }
            return goals
        }
        return nil
    }
    
    func addGoal(_ goal: Note) {
        var goalIds = [String]()
        if let oldIds = UserDefaults.standard.object(forKey: "goal_ids") as? [String] {
            goalIds = oldIds
        }
        goalIds.append(goal.id)
        UserDefaults.standard.set(goalIds, forKey: "goal_ids")
        UserDefaults.standard.set(goal.toJSON(), forKey: "goal_\(goal.id ?? "")")
        UserDefaults.standard.synchronize()
        
        GoalsRemoteManager.manager.addGoal(goal)
    }
    
    func removeGoal(for goalId:String) {
        if let json = UserDefaults.standard.object(forKey: "goal_\(goalId)") as? [String:Any] {
            if let goal = Note(JSON: json) {
                if let goalIds = UserDefaults.standard.object(forKey: "goal_ids") as? [String] {
                    var newGoalIds = [String]()
                    for goalId in goalIds {
                        if goalId != goal.id {
                            newGoalIds.append(goalId)
                        }
                    }
                    UserDefaults.standard.set(goalIds, forKey: "goal_ids")
                }
                UserDefaults.standard.removeObject(forKey: "goal_\(goal.id ?? "")")
                UserDefaults.standard.synchronize()
                GoalsRemoteManager.manager.removeGoal(goal)
            }
        }
    }
    
    func changeGoalTitleAndSubTitle(goalId: String, title: String? = nil, subTitle: String? = nil) {
        if let json = UserDefaults.standard.object(forKey: "goal_\(goalId)") as? [String:Any] {
            if let goal = Note(JSON: json) {
                if title != nil {
                    goal.note = title
                }
                if subTitle != nil {
                    goal.subTitle = subTitle
                }
                UserDefaults.standard.set(goal.toJSON(), forKey: "goal_\(goal.id ?? "")")
                UserDefaults.standard.synchronize()
                GoalsRemoteManager.manager.updateGoal(goal)
            }
        }
    }
    
    func changeGoalArchivedStatus(for goalId: String) {
        if let json = UserDefaults.standard.object(forKey: "goal_\(goalId)") as? [String:Any] {
            if let goal = Note(JSON: json) {
                goal.archived = !goal.archived
                UserDefaults.standard.set(goal.toJSON(), forKey: "goal_\(goal.id ?? "")")
                UserDefaults.standard.synchronize()
                GoalsRemoteManager.manager.updateGoal(goal)
            }
        }
    }
}