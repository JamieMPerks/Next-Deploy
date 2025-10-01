#!/usr/bin/env bash
set -e
if [ -z "$1" ]; then
	echo "Usage: $0 <domain>"
	exit 1
fi

DOMAIN="$1"
CMS_DIR="/var/www/$DOMAIN/cms/src"

echo "==> Generating CMS schema in $CMS_DIR"

# Ensure directories
mkdir -p "$CMS_DIR/api/page/content-types/page"
mkdir -p "$CMS_DIR/api/post/content-types/post"
mkdir -p "$CMS_DIR/components/sections"

##########################################
# PAGE SCHEMA
##########################################
cat >"$CMS_DIR/api/page/content-types/page/schema.json" <<'EOF'
{
  "kind": "collectionType",
  "collectionName": "pages",
  "info": {
    "singularName": "page",
    "pluralName": "pages",
    "displayName": "Page"
  },
  "options": { "draftAndPublish": false },
  "attributes": {
    "title": { "type": "string", "required": true },
    "slug": { "type": "uid", "targetField": "title", "required": true },
    "sections": {
      "type": "dynamiczone",
      "components": ["sections.hero","sections.text-block","sections.services"]
    }
  }
}
EOF

##########################################
# POST SCHEMA
##########################################
cat >"$CMS_DIR/api/post/content-types/post/schema.json" <<'EOF'
{
  "kind": "collectionType",
  "collectionName": "posts",
  "info": {
    "singularName": "post",
    "pluralName": "posts",
    "displayName": "Post"
  },
  "options": { "draftAndPublish": true },
  "attributes": {
    "title": { "type": "string", "required": true },
    "slug": { "type": "uid", "targetField": "title", "required": true },
    "content": { "type": "richtext" },
    "cover": { "type": "media", "multiple": false },
    "publishedAt": { "type": "datetime" }
  }
}
EOF

##########################################
# COMPONENTS
##########################################

# Hero
cat >"$CMS_DIR/components/sections/hero.json" <<'EOF'
{
  "collectionName": "components_hero",
  "info": { "displayName": "Hero" },
  "attributes": {
    "heading": { "type": "string" },
    "subheading": { "type": "string" },
    "background_image": { "type": "media" }
  }
}
EOF

# Text Block
cat >"$CMS_DIR/components/sections/text-block.json" <<'EOF'
{
  "collectionName": "components_text_block",
  "info": { "displayName": "Text Block" },
  "attributes": {
    "content": { "type": "richtext" }
  }
}
EOF

# Services
cat >"$CMS_DIR/components/sections/services.json" <<'EOF'
{
  "collectionName": "components_services",
  "info": { "displayName": "Services" },
  "attributes": {
    "items": {
      "type": "component",
      "repeatable": true,
      "component": "sections.service-item"
    }
  }
}
EOF

# Service Item
cat >"$CMS_DIR/components/sections/service-item.json" <<'EOF'
{
  "collectionName": "components_service_item",
  "info": { "displayName": "Service Item" },
  "attributes": {
    "title": { "type": "string" },
    "description": { "type": "text" }
  }
}
EOF

echo "✅ CMS schema scaffolded for $DOMAIN"
echo "Next step:"
echo "   Run: bash deploy/03-generate-strapi-bootstrap.sh $DOMAIN"
