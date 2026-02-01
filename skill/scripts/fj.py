#!/usr/bin/env python3
"""FamilyJourney API CLI - Manage badges, kids, prizes, and submissions."""

import argparse
import json
import sys
import urllib.request
import urllib.error

def api_request(base_url, token, method, endpoint, data=None):
    """Make an API request."""
    url = f"{base_url.rstrip('/')}/api/v1/{endpoint.lstrip('/')}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        try:
            error_body = json.loads(e.read().decode())
            print(f"Error {e.code}: {json.dumps(error_body, indent=2)}", file=sys.stderr)
        except:
            print(f"Error {e.code}: {e.reason}", file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"Connection error: {e.reason}", file=sys.stderr)
        sys.exit(1)

def fmt_kid(k):
    """Format kid for display."""
    return f"[{k['id']}] {k['name']} - {k.get('total_points', 0)} pts ({k.get('badges_earned', 0)} badges)"

def fmt_badge(b):
    """Format badge for display."""
    status = "✓" if b.get('published') else "○"
    return f"[{b['id']}] {status} {b['title']} ({b.get('points', 0)} pts) - {b.get('category', {}).get('name', 'Uncategorized')}"

def fmt_submission(s):
    """Format submission for display."""
    status_icons = {'pending': '⏳', 'approved': '✓', 'denied': '✗'}
    icon = status_icons.get(s.get('status'), '?')
    kid = s.get('kid', {}).get('name', 'Unknown')
    badge = s.get('badge', {}).get('title', 'Unknown')
    return f"[{s['id']}] {icon} {kid} → {badge} ({s.get('status', 'unknown')})"

def fmt_prize(p):
    """Format prize for display."""
    avail = "✓" if p.get('available', True) else "○"
    return f"[{p['id']}] {avail} {p['name']} ({p.get('points_required', 0)} pts)"

def fmt_redemption(r):
    """Format redemption for display."""
    status_icons = {'pending': '⏳', 'approved': '✓', 'denied': '✗'}
    icon = status_icons.get(r.get('status'), '?')
    kid = r.get('kid', {}).get('name', 'Unknown')
    prize = r.get('prize', {}).get('name', 'Unknown')
    return f"[{r['id']}] {icon} {kid} → {prize} ({r.get('status', 'unknown')})"

def main():
    parser = argparse.ArgumentParser(description="FamilyJourney API CLI")
    parser.add_argument("--token", required=True, help="API token")
    parser.add_argument("--url", default="http://mac-mini:3000", help="Base URL")
    parser.add_argument("--json", action="store_true", help="Output raw JSON")
    
    subparsers = parser.add_subparsers(dest="resource", required=True)
    
    # Kids
    kids_parser = subparsers.add_parser("kids", help="Manage kids")
    kids_sub = kids_parser.add_subparsers(dest="action", required=True)
    kids_sub.add_parser("list", help="List all kids")
    kids_show = kids_sub.add_parser("show", help="Show kid details")
    kids_show.add_argument("id", type=int)
    kids_create = kids_sub.add_parser("create", help="Create a kid")
    kids_create.add_argument("--name", required=True)
    kids_create.add_argument("--username")
    kids_update = kids_sub.add_parser("update", help="Update a kid")
    kids_update.add_argument("id", type=int)
    kids_update.add_argument("--name")
    kids_delete = kids_sub.add_parser("delete", help="Delete a kid")
    kids_delete.add_argument("id", type=int)
    
    # Badges
    badges_parser = subparsers.add_parser("badges", help="Manage badges")
    badges_sub = badges_parser.add_subparsers(dest="action", required=True)
    badges_sub.add_parser("list", help="List all badges")
    badges_show = badges_sub.add_parser("show", help="Show badge details")
    badges_show.add_argument("id", type=int)
    badges_create = badges_sub.add_parser("create", help="Create a badge")
    badges_create.add_argument("--title", required=True)
    badges_create.add_argument("--description")
    badges_create.add_argument("--points", type=int, default=10)
    badges_create.add_argument("--category-id", type=int)
    badges_publish = badges_sub.add_parser("publish", help="Publish a badge")
    badges_publish.add_argument("id", type=int)
    badges_unpublish = badges_sub.add_parser("unpublish", help="Unpublish a badge")
    badges_unpublish.add_argument("id", type=int)
    
    # Submissions
    subs_parser = subparsers.add_parser("submissions", help="Manage badge submissions")
    subs_sub = subs_parser.add_subparsers(dest="action", required=True)
    subs_sub.add_parser("list", help="List submissions")
    subs_show = subs_sub.add_parser("show", help="Show submission details")
    subs_show.add_argument("id", type=int)
    subs_approve = subs_sub.add_parser("approve", help="Approve a submission")
    subs_approve.add_argument("id", type=int)
    subs_deny = subs_sub.add_parser("deny", help="Deny a submission")
    subs_deny.add_argument("id", type=int)
    subs_deny.add_argument("--reason", help="Reason for denial")
    
    # Prizes
    prizes_parser = subparsers.add_parser("prizes", help="Manage prizes")
    prizes_sub = prizes_parser.add_subparsers(dest="action", required=True)
    prizes_sub.add_parser("list", help="List all prizes")
    prizes_show = prizes_sub.add_parser("show", help="Show prize details")
    prizes_show.add_argument("id", type=int)
    prizes_create = prizes_sub.add_parser("create", help="Create a prize")
    prizes_create.add_argument("--name", required=True)
    prizes_create.add_argument("--description")
    prizes_create.add_argument("--points", type=int, required=True, help="Points required")
    prizes_update = prizes_sub.add_parser("update", help="Update a prize")
    prizes_update.add_argument("id", type=int)
    prizes_update.add_argument("--name")
    prizes_update.add_argument("--description")
    prizes_update.add_argument("--points", type=int)
    prizes_delete = prizes_sub.add_parser("delete", help="Delete a prize")
    prizes_delete.add_argument("id", type=int)
    
    # Redemptions
    redeem_parser = subparsers.add_parser("redemptions", help="Manage prize redemptions")
    redeem_sub = redeem_parser.add_subparsers(dest="action", required=True)
    redeem_sub.add_parser("list", help="List redemptions")
    redeem_show = redeem_sub.add_parser("show", help="Show redemption details")
    redeem_show.add_argument("id", type=int)
    redeem_approve = redeem_sub.add_parser("approve", help="Approve a redemption")
    redeem_approve.add_argument("id", type=int)
    redeem_deny = redeem_sub.add_parser("deny", help="Deny a redemption")
    redeem_deny.add_argument("id", type=int)
    redeem_deny.add_argument("--reason", help="Reason for denial")
    
    # Family
    subparsers.add_parser("family", help="Show family overview")
    
    args = parser.parse_args()
    api = lambda m, e, d=None: api_request(args.url, args.token, m, e, d)
    
    # Execute commands
    if args.resource == "kids":
        if args.action == "list":
            result = api("GET", "kids")
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                kids = result if isinstance(result, list) else result.get('kids', [])
                for k in kids:
                    print(fmt_kid(k))
        elif args.action == "show":
            result = api("GET", f"kids/{args.id}")
            print(json.dumps(result, indent=2))
        elif args.action == "create":
            data = {"kid": {"name": args.name}}
            if args.username:
                data["kid"]["username"] = args.username
            result = api("POST", "kids", data)
            print(f"Created: {fmt_kid(result)}")
        elif args.action == "update":
            data = {"kid": {}}
            if args.name:
                data["kid"]["name"] = args.name
            result = api("PATCH", f"kids/{args.id}", data)
            print(f"Updated: {fmt_kid(result)}")
        elif args.action == "delete":
            api("DELETE", f"kids/{args.id}")
            print(f"Deleted kid {args.id}")
            
    elif args.resource == "badges":
        if args.action == "list":
            result = api("GET", "badges")
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                badges = result if isinstance(result, list) else result.get('badges', [])
                for b in badges:
                    print(fmt_badge(b))
        elif args.action == "show":
            result = api("GET", f"badges/{args.id}")
            print(json.dumps(result, indent=2))
        elif args.action == "create":
            data = {"badge": {
                "title": args.title,
                "points": args.points
            }}
            if args.description:
                data["badge"]["description"] = args.description
            if args.category_id:
                data["badge"]["badge_category_id"] = args.category_id
            result = api("POST", "badges", data)
            print(f"Created: {fmt_badge(result)}")
        elif args.action == "publish":
            result = api("POST", f"badges/{args.id}/publish")
            print(f"Published badge {args.id}")
        elif args.action == "unpublish":
            result = api("POST", f"badges/{args.id}/unpublish")
            print(f"Unpublished badge {args.id}")
            
    elif args.resource == "submissions":
        if args.action == "list":
            result = api("GET", "badge_submissions")
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                subs = result if isinstance(result, list) else result.get('submissions', result.get('badge_submissions', []))
                for s in subs:
                    print(fmt_submission(s))
        elif args.action == "show":
            result = api("GET", f"badge_submissions/{args.id}")
            print(json.dumps(result, indent=2))
        elif args.action == "approve":
            result = api("POST", f"badge_submissions/{args.id}/approve")
            print(f"Approved submission {args.id}")
        elif args.action == "deny":
            data = {}
            if args.reason:
                data["reason"] = args.reason
            result = api("POST", f"badge_submissions/{args.id}/deny", data if data else None)
            print(f"Denied submission {args.id}")
            
    elif args.resource == "prizes":
        if args.action == "list":
            result = api("GET", "prizes")
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                prizes = result if isinstance(result, list) else result.get('prizes', [])
                for p in prizes:
                    print(fmt_prize(p))
        elif args.action == "show":
            result = api("GET", f"prizes/{args.id}")
            print(json.dumps(result, indent=2))
        elif args.action == "create":
            data = {"prize": {
                "name": args.name,
                "points_required": args.points
            }}
            if args.description:
                data["prize"]["description"] = args.description
            result = api("POST", "prizes", data)
            print(f"Created: {fmt_prize(result)}")
        elif args.action == "update":
            data = {"prize": {}}
            if args.name:
                data["prize"]["name"] = args.name
            if args.description:
                data["prize"]["description"] = args.description
            if args.points:
                data["prize"]["points_required"] = args.points
            result = api("PATCH", f"prizes/{args.id}", data)
            print(f"Updated: {fmt_prize(result)}")
        elif args.action == "delete":
            api("DELETE", f"prizes/{args.id}")
            print(f"Deleted prize {args.id}")
            
    elif args.resource == "redemptions":
        if args.action == "list":
            result = api("GET", "redemptions")
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                redeems = result if isinstance(result, list) else result.get('redemptions', [])
                for r in redeems:
                    print(fmt_redemption(r))
        elif args.action == "show":
            result = api("GET", f"redemptions/{args.id}")
            print(json.dumps(result, indent=2))
        elif args.action == "approve":
            result = api("POST", f"redemptions/{args.id}/approve")
            print(f"Approved redemption {args.id}")
        elif args.action == "deny":
            data = {}
            if args.reason:
                data["reason"] = args.reason
            result = api("POST", f"redemptions/{args.id}/deny", data if data else None)
            print(f"Denied redemption {args.id}")
            
    elif args.resource == "family":
        result = api("GET", "family")
        print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
