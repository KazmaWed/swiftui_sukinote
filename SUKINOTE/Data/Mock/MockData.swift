//
//  MockData.swift
//  SUKINOTE
//
//  Created by Kazma Wed on 2025/10/24.
//

import Foundation

enum MockData {
    static var sampleNotes: [Note] {
        let now = Date()
        let calendar = Calendar.current

        return [
            // like (3)
            Note(
                createdAt: calendar.date(byAdding: .day, value: -1, to: now)!,
                category: .like,
                title: "Morning Coffee Ritual",
                content: "Flat white with oat milk"
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -5, to: now)!,
                category: .like,
                title: "Lo-fi Jazz Sessions",
                content: "Perfect for coding"
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -10, to: now)!,
                category: .like,
                title: "Kyoto in Spring",
                content: "Walking along the Philosopher's Path during sakura season was absolutely breathtaking. The cherry blossoms formed a pink canopy overhead, with petals gently falling like snow. The sound of water flowing in the canal, mixed with the distant chatter of other visitors, created a peaceful atmosphere. I stopped at a small café halfway through and had matcha with wagashi while watching the petals drift by. This is definitely one of those moments I want to remember forever."
            ),
            // dislike (2)
            Note(
                createdAt: calendar.date(byAdding: .day, value: -2, to: now)!,
                category: .dislike,
                title: "Humid Summer Days",
                content: "Makes me feel sluggish"
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -7, to: now)!,
                category: .dislike,
                title: "Overly Spicy Food",
                content: "Can't taste the flavors"
            ),
            // hobby (3)
            Note(
                createdAt: calendar.date(byAdding: .day, value: -3, to: now)!,
                category: .hobby,
                title: "Street Photography",
                content: "Candid moments in Tokyo"
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -8, to: now)!,
                category: .hobby,
                title: "Growing Herbs",
                content: "Basil and mint on balcony"
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -15, to: now)!,
                category: .hobby,
                title: "Sci-fi Novels",
                content: "Currently reading Foundation"
            ),
            // anniversary (2)
            Note(
                createdAt: calendar.date(byAdding: .day, value: -20, to: now)!,
                category: .anniversary,
                title: "Wedding Day",
                content: "",
                anniversaryDate: calendar.date(from: DateComponents(year: 2020, month: 6, day: 15))!,
                isAnnual: true
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -4, to: now)!,
                category: .anniversary,
                title: "App Launch",
                content: "First version went live",
                anniversaryDate: calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!,
                isAnnual: true
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -12, to: now)!,
                category: .anniversary,
                title: "Started Learning Swift",
                content: "My coding journey began"
            ),
            // family (1)
            Note(
                createdAt: calendar.date(byAdding: .day, value: -6, to: now)!,
                category: .family,
                title: "Weekly Call with Mom",
                content: "Every Sunday at 3pm"
            ),
            // school (2)
            Note(
                createdAt: calendar.date(byAdding: .day, value: -9, to: now)!,
                category: .school,
                title: "iOS Design Patterns",
                content: "MVVM vs TCA comparison"
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -14, to: now)!,
                category: .school,
                title: "Algorithm Study",
                content: "Binary search trees"
            ),
            // work (4)
            Note(
                createdAt: calendar.date(byAdding: .day, value: -30, to: now)!,
                category: .work,
                title: "First Day at StartupCo",
                content: "Nervous but excited. Great team vibes"
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -11, to: now)!,
                category: .work,
                title: "Shipped Major Feature",
                content: "Payment system went live. Celebrated with team dinner"
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -13, to: now)!,
                category: .work,
                title: "Mentor's Advice",
                content: "\"Write code for humans, not machines\""
            ),
            Note(
                createdAt: calendar.date(byAdding: .day, value: -25, to: now)!,
                category: .work,
                title: "Career Pivot Decision",
                content: "Left consulting to join product team"
            ),
        ]
    }
}
