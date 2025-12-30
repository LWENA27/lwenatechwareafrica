

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "inventorymaster";


ALTER SCHEMA "inventorymaster" OWNER TO "postgres";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE SCHEMA IF NOT EXISTS "smartmenu";


ALTER SCHEMA "smartmenu" OWNER TO "postgres";


CREATE SCHEMA IF NOT EXISTS "sms_gateway";


ALTER SCHEMA "sms_gateway" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."add_user_to_client_product"("p_user_id" "uuid", "p_client_id" "uuid", "p_product_schema" "text", "p_tenant_id" "uuid", "p_role" "text" DEFAULT 'member'::"text", "p_user_email" "text" DEFAULT NULL::"text", "p_user_name" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
DECLARE
  v_product_id uuid;
  v_access_id uuid;
BEGIN
  -- Get product ID
  SELECT id INTO v_product_id FROM public.products WHERE schema_name = p_product_schema;
  
  IF v_product_id IS NULL THEN
    RAISE EXCEPTION 'Product schema % not found', p_product_schema;
  END IF;
  
  -- Create or update global user
  INSERT INTO public.global_users (id, email, name, client_id, role)
  VALUES (p_user_id, p_user_email, p_user_name, p_client_id, 'user')
  ON CONFLICT (id) DO UPDATE 
  SET client_id = p_client_id, updated_at = now();
  
  -- Grant access
  INSERT INTO public.client_product_access (user_id, client_id, product_id, tenant_id, role)
  VALUES (p_user_id, p_client_id, v_product_id, p_tenant_id, p_role)
  ON CONFLICT (user_id, client_id, product_id, tenant_id) DO UPDATE
  SET role = p_role, updated_at = now()
  RETURNING id INTO v_access_id;
  
  -- Create profile in product schema
  EXECUTE format('INSERT INTO %I.profiles (id, email, name, tenant_id, role) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (id) DO NOTHING', p_product_schema)
  USING p_user_id, p_user_email, p_user_name, p_tenant_id, p_role;
  
  RETURN v_access_id;
END;
$_$;


ALTER FUNCTION "public"."add_user_to_client_product"("p_user_id" "uuid", "p_client_id" "uuid", "p_product_schema" "text", "p_tenant_id" "uuid", "p_role" "text", "p_user_email" "text", "p_user_name" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_client"("p_owner_id" "uuid", "p_client_name" "text", "p_client_slug" "text", "p_client_email" "text" DEFAULT NULL::"text", "p_owner_name" "text" DEFAULT NULL::"text", "p_owner_email" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_client_id uuid;
BEGIN
  INSERT INTO public.clients (owner_id, name, slug, email)
  VALUES (p_owner_id, p_client_name, p_client_slug, p_client_email)
  RETURNING id INTO v_client_id;
  
  INSERT INTO public.global_users (id, email, name, client_id, is_client_owner, role)
  VALUES (p_owner_id, p_owner_email, p_owner_name, v_client_id, true, 'admin')
  ON CONFLICT (id) DO UPDATE 
  SET client_id = v_client_id, is_client_owner = true, updated_at = now();
  
  RETURN v_client_id;
END;
$$;


ALTER FUNCTION "public"."create_client"("p_owner_id" "uuid", "p_client_name" "text", "p_client_slug" "text", "p_client_email" "text", "p_owner_name" "text", "p_owner_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'sms_gateway'
    AS $$
BEGIN
    RETURN "sms_gateway"."get_sms_request_status"(
        p_api_key,
        p_request_id
    );
END;
$$;


ALTER FUNCTION "public"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_type"("user_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (
        SELECT raw_user_meta_data->>'user_type'
        FROM auth.users
        WHERE id = user_id
    );
END;
$$;


ALTER FUNCTION "public"."get_user_type"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_user_type"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_type text;
BEGIN
    -- Get the user type based on existing records
    SELECT
        CASE
            WHEN EXISTS (SELECT 1 FROM public.farmers WHERE user_id = NEW.id) THEN 'farmer'
            WHEN EXISTS (SELECT 1 FROM public.vets WHERE user_id = NEW.id) THEN 'vet'
            ELSE COALESCE(NEW.raw_user_meta_data->>'user_type', 'unassigned')
        END INTO user_type;

    -- Update user metadata with user_type
    NEW.raw_user_meta_data =
        COALESCE(NEW.raw_user_meta_data, '{}'::jsonb) ||
        jsonb_build_object('user_type', user_type);

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_user_type"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_super_admin"("user_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = user_id AND role = 'super_admin'
    );
END;
$$;


ALTER FUNCTION "public"."is_super_admin"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_usage"("p_product_schema" "text", "p_tenant_id" "uuid", "p_client_id" "uuid", "p_action" "text", "p_details" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_stat_id uuid;
BEGIN
  INSERT INTO public.product_usage_stats (product_id, client_id, tenant_id, metric_name, metric_value, metadata)
  SELECT 
    p.id,
    p_client_id,
    p_tenant_id,
    p_action,
    1,
    p_details || jsonb_build_object('timestamp', now(), 'user_id', auth.uid())
  FROM public.products p
  WHERE p.schema_name = p_product_schema
  RETURNING id INTO v_stat_id;
  
  RETURN v_stat_id;
END;
$$;


ALTER FUNCTION "public"."log_usage"("p_product_schema" "text", "p_tenant_id" "uuid", "p_client_id" "uuid", "p_action" "text", "p_details" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."promote_to_super_admin"("user_email" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_id UUID;
BEGIN
    -- Find user by email
    SELECT auth.users.id INTO user_id
    FROM auth.users
    WHERE auth.users.email = user_email;
    
    IF user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Update or insert profile with super_admin role
    INSERT INTO profiles (id, role, updated_at)
    VALUES (user_id, 'super_admin', NOW())
    ON CONFLICT (id) 
    DO UPDATE SET 
        role = 'super_admin',
        updated_at = NOW();
    
    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."promote_to_super_admin"("user_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."setup_test_admin"("user_email" "text", "user_id" "uuid" DEFAULT NULL::"uuid") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    found_user_id UUID;
    test_tenant_id UUID := '11111111-1111-1111-1111-111111111111';
BEGIN
    -- Find user by email if ID not provided
    IF user_id IS NULL THEN
        SELECT id INTO found_user_id
        FROM auth.users
        WHERE email = user_email
        LIMIT 1;
        
        IF found_user_id IS NULL THEN
            RETURN 'Error: User with email ' || user_email || ' not found';
        END IF;
    ELSE
        found_user_id := user_id;
    END IF;
    
    -- Update or insert profile
    INSERT INTO public.profiles (id, email, role, tenant_id, created_at, updated_at)
    VALUES (found_user_id, user_email, 'admin', test_tenant_id, NOW(), NOW())
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        role = 'admin',
        tenant_id = test_tenant_id,
        updated_at = NOW();
    
    RETURN 'Success: User ' || user_email || ' is now admin of Test Store';
END;
$$;


ALTER FUNCTION "public"."setup_test_admin"("user_email" "text", "user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text" DEFAULT NULL::"text", "p_priority" integer DEFAULT 0, "p_scheduled_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'sms_gateway'
    AS $$
BEGIN
    RETURN "sms_gateway"."submit_bulk_sms_request"(
        p_api_key,
        p_phone_numbers,
        p_message,
        p_external_id,
        p_priority,
        p_scheduled_at,
        p_metadata
    );
END;
$$;


ALTER FUNCTION "public"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text" DEFAULT NULL::"text", "p_priority" integer DEFAULT 0, "p_scheduled_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'sms_gateway'
    AS $$
BEGIN
    RETURN "sms_gateway"."submit_sms_request"(
        p_api_key,
        p_phone_number,
        p_message,
        p_external_id,
        p_priority,
        p_scheduled_at,
        p_metadata
    );
END;
$$;


ALTER FUNCTION "public"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."subscribe_client_to_product"("p_client_id" "uuid", "p_product_schema" "text", "p_tenant_name" "text", "p_tenant_slug" "text", "p_plan_type" "text" DEFAULT 'free'::"text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
DECLARE
  v_product_id uuid;
  v_tenant_id uuid;
  v_client_owner_id uuid;
BEGIN
  SELECT id INTO v_product_id FROM public.products WHERE schema_name = p_product_schema;
  IF v_product_id IS NULL THEN
    RAISE EXCEPTION 'Product schema % not found', p_product_schema;
  END IF;
  
  SELECT owner_id INTO v_client_owner_id FROM public.clients WHERE id = p_client_id;
  IF v_client_owner_id IS NULL THEN
    RAISE EXCEPTION 'Client % not found', p_client_id;
  END IF;
  
  v_tenant_id := gen_random_uuid();
  
  INSERT INTO public.product_subscriptions (product_id, client_id, tenant_id, status, plan_type)
  VALUES (v_product_id, p_client_id, v_tenant_id, 'active', p_plan_type);
  
  INSERT INTO public.client_product_access (user_id, client_id, product_id, tenant_id, role)
  VALUES (v_client_owner_id, p_client_id, v_product_id, v_tenant_id, 'owner');
  
  EXECUTE format('INSERT INTO %I.tenants (id, name, slug, client_id) VALUES ($1, $2, $3, $4)', p_product_schema)
  USING v_tenant_id, p_tenant_name, p_tenant_slug, p_client_id;
  
  RETURN v_tenant_id;
END;
$_$;


ALTER FUNCTION "public"."subscribe_client_to_product"("p_client_id" "uuid", "p_product_schema" "text", "p_tenant_name" "text", "p_tenant_slug" "text", "p_plan_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."track_product_usage"("p_product_schema" "text", "p_client_id" "uuid", "p_tenant_id" "uuid", "p_metric_name" "text", "p_metric_value" numeric, "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_product_id uuid;
  v_stat_id uuid;
BEGIN
  -- Get product ID
  SELECT id INTO v_product_id FROM public.products WHERE schema_name = p_product_schema;
  
  IF v_product_id IS NULL THEN
    RAISE EXCEPTION 'Product schema % not found', p_product_schema;
  END IF;
  
  -- Insert usage stat
  INSERT INTO public.product_usage_stats (product_id, client_id, tenant_id, metric_name, metric_value, metadata)
  VALUES (v_product_id, p_client_id, p_tenant_id, p_metric_name, p_metric_value, p_metadata)
  RETURNING id INTO v_stat_id;
  
  RETURN v_stat_id;
END;
$$;


ALTER FUNCTION "public"."track_product_usage"("p_product_schema" "text", "p_client_id" "uuid", "p_tenant_id" "uuid", "p_metric_name" "text", "p_metric_value" numeric, "p_metadata" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trigger_set_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."trigger_set_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_type"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    IF TG_TABLE_NAME = 'farmers' THEN
        UPDATE auth.users
        SET raw_user_meta_data =
            COALESCE(raw_user_meta_data, '{}'::jsonb) ||
            jsonb_build_object('user_type', 'farmer')
        WHERE id = NEW.user_id;
    ELSIF TG_TABLE_NAME = 'vets' THEN
        UPDATE auth.users
        SET raw_user_meta_data =
            COALESCE(raw_user_meta_data, '{}'::jsonb) ||
            jsonb_build_object('user_type', 'vet')
        WHERE id = NEW.user_id;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_user_type"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."complete_settings_sync"("p_log_id" "uuid", "p_status" "text", "p_error_message" "text" DEFAULT NULL::"text") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway'
    AS $$
BEGIN
    UPDATE settings_sync_log
    SET 
        status = p_status,
        error_message = p_error_message,
        completed_at = now()
    WHERE id = p_log_id;
    
    RETURN jsonb_build_object('success', true, 'message', 'Sync logged');
END;
$$;


ALTER FUNCTION "sms_gateway"."complete_settings_sync"("p_log_id" "uuid", "p_status" "text", "p_error_message" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway'
    AS $$
DECLARE
    v_api_key_id uuid;
    v_user_id uuid;
    v_tenant_id uuid;
    v_is_valid boolean;
    v_request record;
BEGIN
    -- Validate API key
    SELECT * INTO v_api_key_id, v_user_id, v_tenant_id, v_is_valid
    FROM "sms_gateway"."validate_api_key"(p_api_key);
    
    IF v_api_key_id IS NULL OR NOT v_is_valid THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Invalid or inactive API key'
        );
    END IF;
    
    -- Get request status
    SELECT * INTO v_request
    FROM "sms_gateway"."sms_requests"
    WHERE id = p_request_id AND tenant_id = v_tenant_id;
    
    IF v_request IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Request not found'
        );
    END IF;
    
    RETURN jsonb_build_object(
        'success', true,
        'request_id', v_request.id,
        'phone_number', v_request.phone_number,
        'status', v_request.status,
        'external_id', v_request.external_id,
        'created_at', v_request.created_at,
        'processed_at', v_request.processed_at,
        'error_message', v_request.error_message
    );
END;
$$;


ALTER FUNCTION "sms_gateway"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."get_tenant_settings"("p_tenant_id" "uuid") RETURNS TABLE("id" "uuid", "tenant_id" "uuid", "default_sms_channel" "text", "default_sms_sender_id" "text", "daily_sms_quota" integer, "monthly_sms_quota" integer, "enable_bulk_sms" boolean, "enable_scheduled_sms" boolean, "enable_sms_groups" boolean, "enable_api_access" boolean, "api_webhook_url" "text", "plan_type" "text", "sms_cost_per_unit" numeric, "advanced_settings" "jsonb", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "synced_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway'
    AS $$
    SELECT 
        ts.id,
        ts.tenant_id,
        ts.default_sms_channel,
        ts.default_sms_sender_id,
        ts.daily_sms_quota,
        ts.monthly_sms_quota,
        ts.enable_bulk_sms,
        ts.enable_scheduled_sms,
        ts.enable_sms_groups,
        ts.enable_api_access,
        ts.api_webhook_url,
        ts.plan_type,
        ts.sms_cost_per_unit,
        ts.advanced_settings,
        ts.created_at,
        ts.updated_at,
        ts.synced_at
    FROM tenant_settings ts
    WHERE tenant_id = p_tenant_id
$$;


ALTER FUNCTION "sms_gateway"."get_tenant_settings"("p_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."get_user_settings"("p_user_id" "uuid" DEFAULT NULL::"uuid", "p_tenant_id" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("id" "uuid", "user_id" "uuid", "tenant_id" "uuid", "sms_channel" "text", "api_queue_auto_start" boolean, "theme_mode" "text", "language" "text", "notification_on_sms_sent" boolean, "notification_on_sms_failed" boolean, "notification_on_quota_warning" boolean, "additional_settings" "jsonb", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "synced_at" timestamp with time zone)
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway'
    AS $$
    SELECT 
        us.id,
        us.user_id,
        us.tenant_id,
        us.sms_channel,
        us.api_queue_auto_start,
        us.theme_mode,
        us.language,
        us.notification_on_sms_sent,
        us.notification_on_sms_failed,
        us.notification_on_quota_warning,
        us.additional_settings,
        us.created_at,
        us.updated_at,
        us.synced_at
    FROM user_settings us
    WHERE user_id = COALESCE(p_user_id, auth.uid())
    AND tenant_id = COALESCE(p_tenant_id, (
        SELECT id FROM tenants WHERE id = p_tenant_id LIMIT 1
    ))
$$;


ALTER FUNCTION "sms_gateway"."get_user_settings"("p_user_id" "uuid", "p_tenant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."log_settings_sync"("p_user_id" "uuid", "p_tenant_id" "uuid", "p_sync_type" "text", "p_direction" "text", "p_status" "text" DEFAULT 'pending'::"text", "p_error_message" "text" DEFAULT NULL::"text", "p_synced_fields" "text"[] DEFAULT NULL::"text"[]) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway'
    AS $$
DECLARE
    v_log_id uuid;
BEGIN
    INSERT INTO settings_sync_log (
        user_id,
        tenant_id,
        sync_type,
        direction,
        status,
        error_message,
        synced_fields,
        settings_count
    )
    VALUES (
        p_user_id,
        p_tenant_id,
        p_sync_type,
        p_direction,
        p_status,
        p_error_message,
        p_synced_fields,
        COALESCE(array_length(p_synced_fields, 1), 0)
    )
    RETURNING id INTO v_log_id;
    
    RETURN v_log_id;
END;
$$;


ALTER FUNCTION "sms_gateway"."log_settings_sync"("p_user_id" "uuid", "p_tenant_id" "uuid", "p_sync_type" "text", "p_direction" "text", "p_status" "text", "p_error_message" "text", "p_synced_fields" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text" DEFAULT NULL::"text", "p_priority" integer DEFAULT 0, "p_scheduled_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway', 'extensions', 'public'
    AS $$
DECLARE
    v_api_key_id uuid;
    v_user_id uuid;
    v_tenant_id uuid;
    v_is_valid boolean;
    v_request_ids uuid[];
    v_phone text;
    v_request_id uuid;
    v_count integer := 0;
BEGIN
    -- Validate API key
    SELECT * INTO v_api_key_id, v_user_id, v_tenant_id, v_is_valid
    FROM "sms_gateway"."validate_api_key"(p_api_key);
    
    IF v_api_key_id IS NULL OR NOT v_is_valid THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Invalid or inactive API key'
        );
    END IF;
    
    -- Validate message
    IF p_message IS NULL OR length(trim(p_message)) = 0 THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Message cannot be empty'
        );
    END IF;
    
    -- Check recipients count (max 1000 per request)
    IF array_length(p_phone_numbers, 1) > 1000 THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Maximum 1000 recipients per bulk request'
        );
    END IF;
    
    -- Insert SMS requests for each phone number - explicitly set both timestamps
    FOREACH v_phone IN ARRAY p_phone_numbers
    LOOP
        INSERT INTO "sms_gateway"."sms_requests" (
            tenant_id,
            api_key_id,
            phone_number,
            message,
            external_id,
            priority,
            scheduled_at,
            metadata,
            created_at,
            updated_at
        )
        VALUES (
            v_tenant_id,
            v_api_key_id,
            trim(v_phone),
            trim(p_message),
            p_external_id,
            p_priority,
            p_scheduled_at,
            COALESCE(p_metadata, '{}'::jsonb),
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        )
        RETURNING id INTO v_request_id;
        
        v_request_ids := array_append(v_request_ids, v_request_id);
        v_count := v_count + 1;
    END LOOP;
    
    -- Update last_used timestamp on API key
    UPDATE "sms_gateway"."api_keys"
    SET last_used = NOW()
    WHERE id = v_api_key_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'request_ids', v_request_ids,
        'count', v_count,
        'status', 'pending',
        'message', format('%s SMS requests queued successfully', v_count)
    );
END;
$$;


ALTER FUNCTION "sms_gateway"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text" DEFAULT NULL::"text", "p_priority" integer DEFAULT 0, "p_scheduled_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_metadata" "jsonb" DEFAULT '{}'::"jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway', 'extensions', 'public'
    AS $$
DECLARE
    v_api_key_id uuid;
    v_user_id uuid;
    v_tenant_id uuid;
    v_is_valid boolean;
    v_request_id uuid;
    v_rate_count integer;
BEGIN
    -- Validate API key
    SELECT * INTO v_api_key_id, v_user_id, v_tenant_id, v_is_valid
    FROM "sms_gateway"."validate_api_key"(p_api_key);
    
    IF v_api_key_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Invalid API key'
        );
    END IF;
    
    IF NOT v_is_valid THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'API key is inactive'
        );
    END IF;
    
    -- Check rate limit (100 requests per minute per key)
    SELECT COALESCE(SUM(request_count), 0) INTO v_rate_count
    FROM "sms_gateway"."api_rate_limits"
    WHERE api_key_id = v_api_key_id
      AND window_start > NOW() - INTERVAL '1 minute';
    
    IF v_rate_count >= 100 THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Rate limit exceeded. Max 100 requests per minute.'
        );
    END IF;
    
    -- Update rate limit counter
    INSERT INTO "sms_gateway"."api_rate_limits" (api_key_id, window_start, request_count)
    VALUES (v_api_key_id, date_trunc('minute', NOW()), 1)
    ON CONFLICT (api_key_id, window_start) 
    DO UPDATE SET request_count = "sms_gateway"."api_rate_limits".request_count + 1;
    
    -- Validate phone number (basic check)
    IF p_phone_number IS NULL OR length(trim(p_phone_number)) < 10 THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Invalid phone number'
        );
    END IF;
    
    -- Validate message
    IF p_message IS NULL OR length(trim(p_message)) = 0 THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Message cannot be empty'
        );
    END IF;
    
    -- Insert SMS request - explicitly set both timestamps
    INSERT INTO "sms_gateway"."sms_requests" (
        tenant_id,
        api_key_id,
        phone_number,
        message,
        external_id,
        priority,
        scheduled_at,
        metadata,
        created_at,
        updated_at
    )
    VALUES (
        v_tenant_id,
        v_api_key_id,
        trim(p_phone_number),
        trim(p_message),
        p_external_id,
        p_priority,
        p_scheduled_at,
        COALESCE(p_metadata, '{}'::jsonb),
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING id INTO v_request_id;
    
    -- Update last_used timestamp on API key
    UPDATE "sms_gateway"."api_keys"
    SET last_used = NOW()
    WHERE id = v_api_key_id;
    
    RETURN jsonb_build_object(
        'success', true,
        'request_id', v_request_id,
        'status', 'pending',
        'message', 'SMS request queued successfully'
    );
END;
$$;


ALTER FUNCTION "sms_gateway"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."update_tenant_settings_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "sms_gateway"."update_tenant_settings_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."update_user_settings"("p_user_id" "uuid", "p_tenant_id" "uuid", "p_sms_channel" "text" DEFAULT NULL::"text", "p_api_queue_auto_start" boolean DEFAULT NULL::boolean, "p_theme_mode" "text" DEFAULT NULL::"text", "p_language" "text" DEFAULT NULL::"text", "p_notification_on_sms_sent" boolean DEFAULT NULL::boolean, "p_notification_on_sms_failed" boolean DEFAULT NULL::boolean, "p_notification_on_quota_warning" boolean DEFAULT NULL::boolean, "p_additional_settings" "jsonb" DEFAULT NULL::"jsonb") RETURNS "json"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway'
    AS $$
DECLARE
    v_result json;
BEGIN
    INSERT INTO user_settings (
        user_id,
        tenant_id,
        sms_channel,
        api_queue_auto_start,
        theme_mode,
        language,
        notification_on_sms_sent,
        notification_on_sms_failed,
        notification_on_quota_warning,
        additional_settings
    )
    VALUES (
        p_user_id,
        p_tenant_id,
        COALESCE(p_sms_channel, 'thisPhone'),
        COALESCE(p_api_queue_auto_start, false),
        COALESCE(p_theme_mode, 'light'),
        COALESCE(p_language, 'en'),
        COALESCE(p_notification_on_sms_sent, true),
        COALESCE(p_notification_on_sms_failed, true),
        COALESCE(p_notification_on_quota_warning, true),
        COALESCE(p_additional_settings, '{}'::jsonb)
    )
    ON CONFLICT (user_id, tenant_id) 
    DO UPDATE SET
        sms_channel = COALESCE(p_sms_channel, user_settings.sms_channel),
        api_queue_auto_start = COALESCE(p_api_queue_auto_start, user_settings.api_queue_auto_start),
        theme_mode = COALESCE(p_theme_mode, user_settings.theme_mode),
        language = COALESCE(p_language, user_settings.language),
        notification_on_sms_sent = COALESCE(p_notification_on_sms_sent, user_settings.notification_on_sms_sent),
        notification_on_sms_failed = COALESCE(p_notification_on_sms_failed, user_settings.notification_on_sms_failed),
        notification_on_quota_warning = COALESCE(p_notification_on_quota_warning, user_settings.notification_on_quota_warning),
        additional_settings = COALESCE(p_additional_settings, user_settings.additional_settings);
    
    v_result := jsonb_build_object('success', true, 'message', 'Settings updated');
    RETURN v_result;
END;
$$;


ALTER FUNCTION "sms_gateway"."update_user_settings"("p_user_id" "uuid", "p_tenant_id" "uuid", "p_sms_channel" "text", "p_api_queue_auto_start" boolean, "p_theme_mode" "text", "p_language" "text", "p_notification_on_sms_sent" boolean, "p_notification_on_sms_failed" boolean, "p_notification_on_quota_warning" boolean, "p_additional_settings" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."update_user_settings_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "sms_gateway"."update_user_settings_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "sms_gateway"."validate_api_key"("p_api_key" "text") RETURNS TABLE("api_key_id" "uuid", "user_id" "uuid", "tenant_id" "uuid", "is_valid" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'sms_gateway', 'extensions', 'public'
    AS $$
DECLARE
    v_key_hash text;
BEGIN
    -- Hash the provided key (using SHA-256)
    v_key_hash := encode(extensions.digest(p_api_key, 'sha256'), 'hex');
    
    RETURN QUERY
    SELECT 
        ak.id as api_key_id,
        ak.user_id,
        ak.tenant_id,
        (ak.active = true) as is_valid
    FROM "sms_gateway"."api_keys" ak
    WHERE ak.key_hash = v_key_hash
    LIMIT 1;
END;
$$;


ALTER FUNCTION "sms_gateway"."validate_api_key"("p_api_key" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "inventorymaster"."inventories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "sku" "text",
    "quantity" integer DEFAULT 0 NOT NULL,
    "selling_price" numeric,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "category" "text" NOT NULL,
    "brand" "text",
    "description" "text",
    "image_url" "text",
    "buying_price" numeric NOT NULL,
    "visible_to_customers" boolean DEFAULT true
);


ALTER TABLE "inventorymaster"."inventories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "inventorymaster"."profiles" (
    "id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'user'::"text" NOT NULL,
    "email" "text",
    "name" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "tenant_id" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "language" "text" DEFAULT 'en'::"text",
    CONSTRAINT "profiles_role_check" CHECK (("role" = ANY (ARRAY['user'::"text", 'admin'::"text", 'staff'::"text", 'super_admin'::"text"])))
);


ALTER TABLE "inventorymaster"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "inventorymaster"."sales" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "product_name" "text" NOT NULL,
    "quantity" integer NOT NULL,
    "unit_price" numeric NOT NULL,
    "total_amount" numeric NOT NULL,
    "customer_name" "text" NOT NULL,
    "customer_phone" "text" NOT NULL,
    "date" timestamp with time zone DEFAULT "now"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "receipt_number" "text",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "business_address" "text",
    "business_name" "text",
    "business_phone" numeric,
    "business_tin" numeric
);


ALTER TABLE "inventorymaster"."sales" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "inventorymaster"."tenants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "client_id" "uuid" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "public_storefront" boolean DEFAULT true,
    "show_products_to_customers" boolean DEFAULT true,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "inventorymaster"."tenants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."client_product_access" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "client_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'member'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "client_product_access_role_check" CHECK (("role" = ANY (ARRAY['owner'::"text", 'admin'::"text", 'member'::"text", 'viewer'::"text"])))
);


ALTER TABLE "public"."client_product_access" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."clients" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "email" "text",
    "phone" "text",
    "address" "text",
    "country" "text",
    "owner_id" "uuid" NOT NULL,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb"
);


ALTER TABLE "public"."clients" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."global_users" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "name" "text",
    "client_id" "uuid",
    "role" "text" DEFAULT 'user'::"text" NOT NULL,
    "is_client_owner" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "global_users_role_check" CHECK (("role" = ANY (ARRAY['user'::"text", 'admin'::"text", 'staff'::"text", 'super_admin'::"text"])))
);


ALTER TABLE "public"."global_users" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."product_subscriptions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "client_id" "uuid" NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "plan_type" "text" DEFAULT 'free'::"text",
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "product_subscriptions_plan_check" CHECK (("plan_type" = ANY (ARRAY['free'::"text", 'basic'::"text", 'pro'::"text", 'enterprise'::"text"]))),
    CONSTRAINT "product_subscriptions_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'suspended'::"text", 'cancelled'::"text", 'expired'::"text", 'trial'::"text"])))
);


ALTER TABLE "public"."product_subscriptions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."product_usage_stats" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "product_id" "uuid" NOT NULL,
    "client_id" "uuid" NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "metric_name" "text" NOT NULL,
    "metric_value" numeric DEFAULT 0 NOT NULL,
    "recorded_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb"
);


ALTER TABLE "public"."product_usage_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "schema_name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    CONSTRAINT "products_schema_name_check" CHECK (("schema_name" ~ '^[a-z_][a-z0-9_]*$'::"text"))
);


ALTER TABLE "public"."products" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_client_overview" AS
 SELECT "c"."id",
    "c"."name",
    "c"."slug",
    "c"."email",
    "c"."is_active",
    "gu"."name" AS "owner_name",
    "gu"."email" AS "owner_email",
    "count"(DISTINCT "ps"."product_id") AS "products_subscribed",
    "count"(DISTINCT "u"."id") AS "total_users",
    "c"."created_at"
   FROM ((("public"."clients" "c"
     LEFT JOIN "public"."global_users" "gu" ON (("c"."owner_id" = "gu"."id")))
     LEFT JOIN "public"."product_subscriptions" "ps" ON (("c"."id" = "ps"."client_id")))
     LEFT JOIN "public"."global_users" "u" ON (("c"."id" = "u"."client_id")))
  GROUP BY "c"."id", "c"."name", "c"."slug", "c"."email", "c"."is_active", "gu"."name", "gu"."email", "c"."created_at";


ALTER TABLE "public"."v_client_overview" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_product_overview" AS
 SELECT "p"."id",
    "p"."name",
    "p"."schema_name",
    "p"."is_active",
    "count"(DISTINCT "ps"."client_id") AS "client_count",
    "count"(DISTINCT "cpa"."user_id") AS "user_count",
    "count"(DISTINCT
        CASE
            WHEN ("ps"."status" = 'active'::"text") THEN "ps"."id"
            ELSE NULL::"uuid"
        END) AS "active_subscriptions",
    "p"."created_at"
   FROM (("public"."products" "p"
     LEFT JOIN "public"."product_subscriptions" "ps" ON (("p"."id" = "ps"."product_id")))
     LEFT JOIN "public"."client_product_access" "cpa" ON (("p"."id" = "cpa"."product_id")))
  GROUP BY "p"."id", "p"."name", "p"."schema_name", "p"."is_active", "p"."created_at";


ALTER TABLE "public"."v_product_overview" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_subscription_summary" AS
 SELECT "p"."name" AS "product_name",
    "c"."name" AS "client_name",
    "ps"."status",
    "ps"."plan_type",
    "ps"."started_at",
    "ps"."expires_at"
   FROM (("public"."product_subscriptions" "ps"
     JOIN "public"."products" "p" ON (("ps"."product_id" = "p"."id")))
     JOIN "public"."clients" "c" ON (("ps"."client_id" = "c"."id")))
  ORDER BY "ps"."created_at" DESC;


ALTER TABLE "public"."v_subscription_summary" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."v_user_access_overview" AS
 SELECT "gu"."id",
    "gu"."name",
    "gu"."email",
    "c"."name" AS "client_name",
    "gu"."is_client_owner",
    "count"(DISTINCT "cpa"."product_id") AS "products_access",
    "json_agg"("json_build_object"('product_name', "p"."name", 'role', "cpa"."role", 'tenant_id', "cpa"."tenant_id")) FILTER (WHERE ("p"."id" IS NOT NULL)) AS "product_access_details"
   FROM ((("public"."global_users" "gu"
     LEFT JOIN "public"."clients" "c" ON (("gu"."client_id" = "c"."id")))
     LEFT JOIN "public"."client_product_access" "cpa" ON (("gu"."id" = "cpa"."user_id")))
     LEFT JOIN "public"."products" "p" ON (("cpa"."product_id" = "p"."id")))
  GROUP BY "gu"."id", "gu"."name", "gu"."email", "c"."name", "gu"."is_client_owner";


ALTER TABLE "public"."v_user_access_overview" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "smartmenu"."profiles" (
    "id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'user'::"text" NOT NULL,
    "email" "text",
    "name" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "tenant_id" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "smartmenu"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "smartmenu"."tenants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "client_id" "uuid" NOT NULL,
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "smartmenu"."tenants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."api_keys" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" character varying(255) NOT NULL,
    "key_hash" character varying(255) NOT NULL,
    "last_used" timestamp with time zone,
    "active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "sms_gateway"."api_keys" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."api_rate_limits" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "api_key_id" "uuid" NOT NULL,
    "window_start" timestamp with time zone NOT NULL,
    "request_count" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE "sms_gateway"."api_rate_limits" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."audit_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "action" character varying(100) NOT NULL,
    "table_name" character varying(100),
    "record_id" "uuid",
    "old_values" "jsonb",
    "new_values" "jsonb",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "sms_gateway"."audit_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."contacts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" character varying(255) NOT NULL,
    "phone_number" character varying(20) NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "sms_gateway"."contacts" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."group_members" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "group_id" "uuid" NOT NULL,
    "contact_id" "uuid" NOT NULL,
    "added_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "sms_gateway"."group_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."groups" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" character varying(255) NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "sms_gateway"."groups" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "setting_key" character varying(255) NOT NULL,
    "setting_value" "jsonb",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "sms_gateway"."settings" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."settings_sync_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "tenant_id" "uuid" NOT NULL,
    "sync_type" "text" NOT NULL,
    "direction" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text",
    "error_message" "text",
    "settings_count" integer DEFAULT 0,
    "synced_fields" "text"[],
    "created_at" timestamp with time zone DEFAULT "now"(),
    "completed_at" timestamp with time zone,
    CONSTRAINT "settings_sync_log_direction_check" CHECK (("direction" = ANY (ARRAY['local_to_remote'::"text", 'remote_to_local'::"text", 'bidirectional'::"text"]))),
    CONSTRAINT "settings_sync_log_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'success'::"text", 'failed'::"text", 'partial'::"text"]))),
    CONSTRAINT "settings_sync_log_sync_type_check" CHECK (("sync_type" = ANY (ARRAY['user_settings'::"text", 'tenant_settings'::"text", 'both'::"text"])))
);


ALTER TABLE "sms_gateway"."settings_sync_log" OWNER TO "postgres";


COMMENT ON TABLE "sms_gateway"."settings_sync_log" IS 'Audit log for settings synchronization between local and remote';



CREATE TABLE IF NOT EXISTS "sms_gateway"."sms_logs" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "contact_id" "uuid",
    "phone_number" character varying(20) NOT NULL,
    "message" "text" NOT NULL,
    "status" character varying(50) DEFAULT 'pending'::character varying,
    "sent_at" timestamp with time zone,
    "error_message" "text",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid" NOT NULL
);


ALTER TABLE "sms_gateway"."sms_logs" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."sms_requests" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "api_key_id" "uuid" NOT NULL,
    "phone_number" character varying(20) NOT NULL,
    "message" "text" NOT NULL,
    "status" character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    "priority" integer DEFAULT 0,
    "scheduled_at" timestamp with time zone,
    "processed_at" timestamp with time zone,
    "error_message" "text",
    "external_id" character varying(255),
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "sms_requests_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'sent'::character varying, 'failed'::character varying, 'cancelled'::character varying])::"text"[])))
);


ALTER TABLE "sms_gateway"."sms_requests" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "sms_gateway"."tenant_members" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'member'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "tenant_members_role_check" CHECK (("role" = ANY (ARRAY['owner'::"text", 'admin'::"text", 'member'::"text"])))
);


ALTER TABLE "sms_gateway"."tenant_members" OWNER TO "postgres";


COMMENT ON TABLE "sms_gateway"."tenant_members" IS 'SMS Gateway Tenant Members - tracks user membership and roles';



CREATE TABLE IF NOT EXISTS "sms_gateway"."tenant_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "default_sms_channel" "text" DEFAULT 'thisPhone'::"text",
    "default_sms_sender_id" "text",
    "daily_sms_quota" integer DEFAULT 10000,
    "monthly_sms_quota" integer DEFAULT 100000,
    "enable_bulk_sms" boolean DEFAULT true,
    "enable_scheduled_sms" boolean DEFAULT true,
    "enable_sms_groups" boolean DEFAULT true,
    "enable_api_access" boolean DEFAULT true,
    "api_webhook_url" "text",
    "api_webhook_secret" "text",
    "plan_type" "text" DEFAULT 'basic'::"text",
    "sms_cost_per_unit" numeric(10,4) DEFAULT 0.05,
    "advanced_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "synced_at" timestamp with time zone,
    "created_by" "uuid",
    "updated_by" "uuid",
    CONSTRAINT "tenant_settings_default_sms_channel_check" CHECK (("default_sms_channel" = ANY (ARRAY['thisPhone'::"text", 'quickSMS'::"text"]))),
    CONSTRAINT "tenant_settings_plan_type_check" CHECK (("plan_type" = ANY (ARRAY['basic'::"text", 'pro'::"text", 'enterprise'::"text"])))
);


ALTER TABLE "sms_gateway"."tenant_settings" OWNER TO "postgres";


COMMENT ON TABLE "sms_gateway"."tenant_settings" IS 'Tenant-wide settings and configuration';



CREATE TABLE IF NOT EXISTS "sms_gateway"."tenants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "status" "text" DEFAULT 'active'::"text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "client_id" "uuid",
    CONSTRAINT "tenants_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'inactive'::"text", 'suspended'::"text"])))
);


ALTER TABLE "sms_gateway"."tenants" OWNER TO "postgres";


COMMENT ON TABLE "sms_gateway"."tenants" IS 'SMS Gateway Tenants (Multi-tenant support)';



CREATE TABLE IF NOT EXISTS "sms_gateway"."user_settings" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "tenant_id" "uuid" NOT NULL,
    "sms_channel" "text" DEFAULT 'thisPhone'::"text",
    "api_queue_auto_start" boolean DEFAULT false,
    "theme_mode" "text" DEFAULT 'light'::"text",
    "language" "text" DEFAULT 'en'::"text",
    "notification_on_sms_sent" boolean DEFAULT true,
    "notification_on_sms_failed" boolean DEFAULT true,
    "notification_on_quota_warning" boolean DEFAULT true,
    "additional_settings" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "synced_at" timestamp with time zone,
    CONSTRAINT "user_settings_sms_channel_check" CHECK (("sms_channel" = ANY (ARRAY['thisPhone'::"text", 'quickSMS'::"text"]))),
    CONSTRAINT "user_settings_theme_mode_check" CHECK (("theme_mode" = ANY (ARRAY['light'::"text", 'dark'::"text", 'system'::"text"])))
);


ALTER TABLE "sms_gateway"."user_settings" OWNER TO "postgres";


COMMENT ON TABLE "sms_gateway"."user_settings" IS 'Per-user preferences and settings for SMS Gateway';



CREATE TABLE IF NOT EXISTS "sms_gateway"."users" (
    "id" "uuid" NOT NULL,
    "email" character varying(255) NOT NULL,
    "name" character varying(255),
    "phone_number" character varying(20),
    "role" character varying(50) DEFAULT 'user'::character varying,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "tenant_id" "uuid"
);


ALTER TABLE "sms_gateway"."users" OWNER TO "postgres";


ALTER TABLE ONLY "inventorymaster"."inventories"
    ADD CONSTRAINT "inventories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "inventorymaster"."inventories"
    ADD CONSTRAINT "inventories_sku_tenant_unique" UNIQUE ("sku", "tenant_id");



ALTER TABLE ONLY "inventorymaster"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "inventorymaster"."sales"
    ADD CONSTRAINT "sales_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "inventorymaster"."tenants"
    ADD CONSTRAINT "tenants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "inventorymaster"."tenants"
    ADD CONSTRAINT "tenants_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."client_product_access"
    ADD CONSTRAINT "client_product_access_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."client_product_access"
    ADD CONSTRAINT "client_product_access_unique" UNIQUE ("user_id", "client_id", "product_id", "tenant_id");



ALTER TABLE ONLY "public"."clients"
    ADD CONSTRAINT "clients_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."clients"
    ADD CONSTRAINT "clients_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."global_users"
    ADD CONSTRAINT "global_users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."global_users"
    ADD CONSTRAINT "global_users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."product_subscriptions"
    ADD CONSTRAINT "product_subscriptions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."product_subscriptions"
    ADD CONSTRAINT "product_subscriptions_unique_product_client" UNIQUE ("product_id", "client_id", "tenant_id");



ALTER TABLE ONLY "public"."product_usage_stats"
    ADD CONSTRAINT "product_usage_stats_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_schema_name_key" UNIQUE ("schema_name");



ALTER TABLE ONLY "smartmenu"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "smartmenu"."tenants"
    ADD CONSTRAINT "tenants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "smartmenu"."tenants"
    ADD CONSTRAINT "tenants_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "sms_gateway"."api_keys"
    ADD CONSTRAINT "api_keys_key_hash_key" UNIQUE ("key_hash");



ALTER TABLE ONLY "sms_gateway"."api_keys"
    ADD CONSTRAINT "api_keys_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."api_rate_limits"
    ADD CONSTRAINT "api_rate_limits_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."api_rate_limits"
    ADD CONSTRAINT "api_rate_limits_unique" UNIQUE ("api_key_id", "window_start");



ALTER TABLE ONLY "sms_gateway"."audit_logs"
    ADD CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."contacts"
    ADD CONSTRAINT "contacts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."group_members"
    ADD CONSTRAINT "group_members_group_id_contact_id_key" UNIQUE ("group_id", "contact_id");



ALTER TABLE ONLY "sms_gateway"."group_members"
    ADD CONSTRAINT "group_members_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."groups"
    ADD CONSTRAINT "groups_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."settings"
    ADD CONSTRAINT "settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."settings_sync_log"
    ADD CONSTRAINT "settings_sync_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."settings"
    ADD CONSTRAINT "settings_user_id_setting_key_key" UNIQUE ("user_id", "setting_key");



ALTER TABLE ONLY "sms_gateway"."sms_logs"
    ADD CONSTRAINT "sms_logs_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."sms_requests"
    ADD CONSTRAINT "sms_requests_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."tenant_members"
    ADD CONSTRAINT "tenant_members_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."tenant_members"
    ADD CONSTRAINT "tenant_members_tenant_id_user_id_key" UNIQUE ("tenant_id", "user_id");



ALTER TABLE ONLY "sms_gateway"."tenant_settings"
    ADD CONSTRAINT "tenant_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."tenant_settings"
    ADD CONSTRAINT "tenant_settings_tenant_id_key" UNIQUE ("tenant_id");



ALTER TABLE ONLY "sms_gateway"."tenants"
    ADD CONSTRAINT "tenants_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."tenants"
    ADD CONSTRAINT "tenants_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "sms_gateway"."user_settings"
    ADD CONSTRAINT "user_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "sms_gateway"."user_settings"
    ADD CONSTRAINT "user_settings_user_id_tenant_id_key" UNIQUE ("user_id", "tenant_id");



ALTER TABLE ONLY "sms_gateway"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "sms_gateway"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_im_inventories_category" ON "inventorymaster"."inventories" USING "btree" ("category");



CREATE INDEX "idx_im_inventories_sku" ON "inventorymaster"."inventories" USING "btree" ("sku");



CREATE INDEX "idx_im_inventories_tenant_id" ON "inventorymaster"."inventories" USING "btree" ("tenant_id");



CREATE INDEX "idx_im_profiles_email" ON "inventorymaster"."profiles" USING "btree" ("email");



CREATE INDEX "idx_im_profiles_tenant_id" ON "inventorymaster"."profiles" USING "btree" ("tenant_id");



CREATE INDEX "idx_im_sales_date" ON "inventorymaster"."sales" USING "btree" ("date");



CREATE INDEX "idx_im_sales_product_id" ON "inventorymaster"."sales" USING "btree" ("product_id");



CREATE INDEX "idx_im_sales_receipt_number" ON "inventorymaster"."sales" USING "btree" ("receipt_number");



CREATE INDEX "idx_im_sales_tenant_id" ON "inventorymaster"."sales" USING "btree" ("tenant_id");



CREATE INDEX "idx_im_tenants_client_id" ON "inventorymaster"."tenants" USING "btree" ("client_id");



CREATE INDEX "idx_im_tenants_slug" ON "inventorymaster"."tenants" USING "btree" ("slug");



CREATE INDEX "idx_client_product_access_client_id" ON "public"."client_product_access" USING "btree" ("client_id");



CREATE INDEX "idx_client_product_access_product_id" ON "public"."client_product_access" USING "btree" ("product_id");



CREATE INDEX "idx_client_product_access_tenant_id" ON "public"."client_product_access" USING "btree" ("tenant_id");



CREATE INDEX "idx_client_product_access_user_id" ON "public"."client_product_access" USING "btree" ("user_id");



CREATE INDEX "idx_clients_is_active" ON "public"."clients" USING "btree" ("is_active");



CREATE INDEX "idx_clients_owner_id" ON "public"."clients" USING "btree" ("owner_id");



CREATE INDEX "idx_clients_slug" ON "public"."clients" USING "btree" ("slug");



CREATE INDEX "idx_global_users_client_id" ON "public"."global_users" USING "btree" ("client_id");



CREATE INDEX "idx_global_users_email" ON "public"."global_users" USING "btree" ("email");



CREATE INDEX "idx_global_users_is_client_owner" ON "public"."global_users" USING "btree" ("is_client_owner");



CREATE INDEX "idx_product_subscriptions_client_id" ON "public"."product_subscriptions" USING "btree" ("client_id");



CREATE INDEX "idx_product_subscriptions_product_id" ON "public"."product_subscriptions" USING "btree" ("product_id");



CREATE INDEX "idx_product_subscriptions_status" ON "public"."product_subscriptions" USING "btree" ("status");



CREATE INDEX "idx_product_subscriptions_tenant_id" ON "public"."product_subscriptions" USING "btree" ("tenant_id");



CREATE INDEX "idx_product_usage_stats_client_id" ON "public"."product_usage_stats" USING "btree" ("client_id");



CREATE INDEX "idx_product_usage_stats_product_id" ON "public"."product_usage_stats" USING "btree" ("product_id");



CREATE INDEX "idx_product_usage_stats_recorded_at" ON "public"."product_usage_stats" USING "btree" ("recorded_at");



CREATE INDEX "idx_product_usage_stats_tenant_id" ON "public"."product_usage_stats" USING "btree" ("tenant_id");



CREATE INDEX "idx_products_is_active" ON "public"."products" USING "btree" ("is_active");



CREATE INDEX "idx_products_schema_name" ON "public"."products" USING "btree" ("schema_name");



CREATE INDEX "idx_sm_profiles_tenant_id" ON "smartmenu"."profiles" USING "btree" ("tenant_id");



CREATE INDEX "idx_sm_tenants_client_id" ON "smartmenu"."tenants" USING "btree" ("client_id");



CREATE INDEX "idx_sm_tenants_slug" ON "smartmenu"."tenants" USING "btree" ("slug");



CREATE INDEX "idx_settings_sync_log_created_at" ON "sms_gateway"."settings_sync_log" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_settings_sync_log_tenant_id" ON "sms_gateway"."settings_sync_log" USING "btree" ("tenant_id");



CREATE INDEX "idx_settings_sync_log_user_id" ON "sms_gateway"."settings_sync_log" USING "btree" ("user_id");



CREATE INDEX "idx_sms_gateway_api_keys_tenant_id" ON "sms_gateway"."api_keys" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_gateway_api_keys_user_id" ON "sms_gateway"."api_keys" USING "btree" ("user_id");



CREATE INDEX "idx_sms_gateway_audit_logs_tenant_id" ON "sms_gateway"."audit_logs" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_gateway_audit_logs_user_id" ON "sms_gateway"."audit_logs" USING "btree" ("user_id");



CREATE INDEX "idx_sms_gateway_contacts_tenant_id" ON "sms_gateway"."contacts" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_gateway_contacts_user_id" ON "sms_gateway"."contacts" USING "btree" ("user_id");



CREATE INDEX "idx_sms_gateway_contacts_user_tenant" ON "sms_gateway"."contacts" USING "btree" ("user_id", "tenant_id");



CREATE INDEX "idx_sms_gateway_group_members_contact_id" ON "sms_gateway"."group_members" USING "btree" ("contact_id");



CREATE INDEX "idx_sms_gateway_group_members_group_id" ON "sms_gateway"."group_members" USING "btree" ("group_id");



CREATE INDEX "idx_sms_gateway_group_members_tenant_id" ON "sms_gateway"."group_members" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_gateway_groups_tenant_id" ON "sms_gateway"."groups" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_gateway_groups_user_id" ON "sms_gateway"."groups" USING "btree" ("user_id");



CREATE INDEX "idx_sms_gateway_groups_user_tenant" ON "sms_gateway"."groups" USING "btree" ("user_id", "tenant_id");



CREATE INDEX "idx_sms_gateway_settings_tenant_id" ON "sms_gateway"."settings" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_gateway_settings_user_id" ON "sms_gateway"."settings" USING "btree" ("user_id");



CREATE INDEX "idx_sms_gateway_sms_logs_created_at" ON "sms_gateway"."sms_logs" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_sms_gateway_sms_logs_status" ON "sms_gateway"."sms_logs" USING "btree" ("status");



CREATE INDEX "idx_sms_gateway_sms_logs_tenant_id" ON "sms_gateway"."sms_logs" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_gateway_sms_logs_user_id" ON "sms_gateway"."sms_logs" USING "btree" ("user_id");



CREATE INDEX "idx_sms_gateway_sms_logs_user_tenant" ON "sms_gateway"."sms_logs" USING "btree" ("user_id", "tenant_id");



CREATE INDEX "idx_sms_gateway_tenant_members_role" ON "sms_gateway"."tenant_members" USING "btree" ("role");



CREATE INDEX "idx_sms_gateway_tenant_members_tenant_id" ON "sms_gateway"."tenant_members" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_gateway_tenant_members_user_id" ON "sms_gateway"."tenant_members" USING "btree" ("user_id");



CREATE INDEX "idx_sms_gateway_tenants_client_id" ON "sms_gateway"."tenants" USING "btree" ("client_id");



CREATE INDEX "idx_sms_gateway_tenants_slug" ON "sms_gateway"."tenants" USING "btree" ("slug");



CREATE INDEX "idx_sms_gateway_tenants_status" ON "sms_gateway"."tenants" USING "btree" ("status");



CREATE INDEX "idx_sms_gateway_users_tenant_id" ON "sms_gateway"."users" USING "btree" ("tenant_id");



CREATE INDEX "idx_sms_requests_api_key" ON "sms_gateway"."sms_requests" USING "btree" ("api_key_id");



CREATE INDEX "idx_sms_requests_external_id" ON "sms_gateway"."sms_requests" USING "btree" ("external_id") WHERE ("external_id" IS NOT NULL);



CREATE INDEX "idx_sms_requests_pending" ON "sms_gateway"."sms_requests" USING "btree" ("status", "priority" DESC, "created_at") WHERE (("status")::"text" = 'pending'::"text");



CREATE INDEX "idx_sms_requests_scheduled" ON "sms_gateway"."sms_requests" USING "btree" ("scheduled_at") WHERE ((("status")::"text" = 'pending'::"text") AND ("scheduled_at" IS NOT NULL));



CREATE INDEX "idx_sms_requests_tenant_status" ON "sms_gateway"."sms_requests" USING "btree" ("tenant_id", "status");



CREATE INDEX "idx_tenant_settings_tenant_id" ON "sms_gateway"."tenant_settings" USING "btree" ("tenant_id");



CREATE INDEX "idx_tenant_settings_updated_at" ON "sms_gateway"."tenant_settings" USING "btree" ("updated_at");



CREATE INDEX "idx_user_settings_tenant_id" ON "sms_gateway"."user_settings" USING "btree" ("tenant_id");



CREATE INDEX "idx_user_settings_updated_at" ON "sms_gateway"."user_settings" USING "btree" ("updated_at");



CREATE INDEX "idx_user_settings_user_id" ON "sms_gateway"."user_settings" USING "btree" ("user_id");



CREATE OR REPLACE TRIGGER "trigger_tenant_settings_updated_at" BEFORE UPDATE ON "sms_gateway"."tenant_settings" FOR EACH ROW EXECUTE FUNCTION "sms_gateway"."update_tenant_settings_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_user_settings_updated_at" BEFORE UPDATE ON "sms_gateway"."user_settings" FOR EACH ROW EXECUTE FUNCTION "sms_gateway"."update_user_settings_updated_at"();



ALTER TABLE ONLY "inventorymaster"."inventories"
    ADD CONSTRAINT "inventories_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "inventorymaster"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "inventorymaster"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "inventorymaster"."profiles"
    ADD CONSTRAINT "profiles_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "inventorymaster"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "inventorymaster"."sales"
    ADD CONSTRAINT "sales_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "inventorymaster"."inventories"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "inventorymaster"."sales"
    ADD CONSTRAINT "sales_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "inventorymaster"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "inventorymaster"."tenants"
    ADD CONSTRAINT "tenants_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."client_product_access"
    ADD CONSTRAINT "client_product_access_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."client_product_access"
    ADD CONSTRAINT "client_product_access_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."client_product_access"
    ADD CONSTRAINT "client_product_access_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."clients"
    ADD CONSTRAINT "clients_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."global_users"
    ADD CONSTRAINT "global_users_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."global_users"
    ADD CONSTRAINT "global_users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product_subscriptions"
    ADD CONSTRAINT "product_subscriptions_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product_subscriptions"
    ADD CONSTRAINT "product_subscriptions_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product_usage_stats"
    ADD CONSTRAINT "product_usage_stats_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product_usage_stats"
    ADD CONSTRAINT "product_usage_stats_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "smartmenu"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "smartmenu"."profiles"
    ADD CONSTRAINT "profiles_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "smartmenu"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "smartmenu"."tenants"
    ADD CONSTRAINT "tenants_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."api_keys"
    ADD CONSTRAINT "api_keys_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "sms_gateway"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."api_rate_limits"
    ADD CONSTRAINT "api_rate_limits_api_key_id_fkey" FOREIGN KEY ("api_key_id") REFERENCES "sms_gateway"."api_keys"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."audit_logs"
    ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "sms_gateway"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."contacts"
    ADD CONSTRAINT "contacts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "sms_gateway"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."group_members"
    ADD CONSTRAINT "group_members_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "sms_gateway"."contacts"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."group_members"
    ADD CONSTRAINT "group_members_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "sms_gateway"."groups"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."groups"
    ADD CONSTRAINT "groups_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "sms_gateway"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."settings_sync_log"
    ADD CONSTRAINT "settings_sync_log_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "sms_gateway"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."settings_sync_log"
    ADD CONSTRAINT "settings_sync_log_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."settings"
    ADD CONSTRAINT "settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "sms_gateway"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."sms_logs"
    ADD CONSTRAINT "sms_logs_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "sms_gateway"."contacts"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "sms_gateway"."sms_logs"
    ADD CONSTRAINT "sms_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "sms_gateway"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."sms_requests"
    ADD CONSTRAINT "sms_requests_api_key_id_fkey" FOREIGN KEY ("api_key_id") REFERENCES "sms_gateway"."api_keys"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."tenant_members"
    ADD CONSTRAINT "tenant_members_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "sms_gateway"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."tenant_members"
    ADD CONSTRAINT "tenant_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."tenant_settings"
    ADD CONSTRAINT "tenant_settings_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "sms_gateway"."tenant_settings"
    ADD CONSTRAINT "tenant_settings_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "sms_gateway"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."tenant_settings"
    ADD CONSTRAINT "tenant_settings_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "sms_gateway"."tenants"
    ADD CONSTRAINT "tenants_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."user_settings"
    ADD CONSTRAINT "user_settings_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "sms_gateway"."tenants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."user_settings"
    ADD CONSTRAINT "user_settings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "sms_gateway"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Users can access inventories in their tenant" ON "inventorymaster"."inventories" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."client_product_access" "cpa"
     JOIN "public"."products" "p" ON (("cpa"."product_id" = "p"."id")))
  WHERE (("cpa"."user_id" = "auth"."uid"()) AND ("p"."schema_name" = 'inventorymaster'::"text") AND ("cpa"."tenant_id" = "inventories"."tenant_id")))));



CREATE POLICY "Users can access sales in their tenant" ON "inventorymaster"."sales" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."client_product_access" "cpa"
     JOIN "public"."products" "p" ON (("cpa"."product_id" = "p"."id")))
  WHERE (("cpa"."user_id" = "auth"."uid"()) AND ("p"."schema_name" = 'inventorymaster'::"text") AND ("cpa"."tenant_id" = "sales"."tenant_id")))));



CREATE POLICY "Users can access their profile" ON "inventorymaster"."profiles" TO "authenticated" USING ((("id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM ("public"."client_product_access" "cpa"
     JOIN "public"."products" "p" ON (("cpa"."product_id" = "p"."id")))
  WHERE (("cpa"."user_id" = "auth"."uid"()) AND ("p"."schema_name" = 'inventorymaster'::"text") AND ("cpa"."tenant_id" = "profiles"."tenant_id") AND ("cpa"."role" = ANY (ARRAY['owner'::"text", 'admin'::"text"])))))));



CREATE POLICY "Users can access their tenant data" ON "inventorymaster"."tenants" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."client_product_access" "cpa"
     JOIN "public"."products" "p" ON (("cpa"."product_id" = "p"."id")))
  WHERE (("cpa"."user_id" = "auth"."uid"()) AND ("p"."schema_name" = 'inventorymaster'::"text") AND ("cpa"."tenant_id" = "tenants"."id")))));



ALTER TABLE "inventorymaster"."inventories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "inventorymaster"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "inventorymaster"."sales" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "inventorymaster"."tenants" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Anyone can view active products" ON "public"."products" FOR SELECT TO "authenticated", "anon" USING (("is_active" = true));



CREATE POLICY "Client owners can update their client" ON "public"."clients" FOR UPDATE TO "authenticated" USING (("owner_id" = "auth"."uid"()));



CREATE POLICY "Users can view subscriptions of their client" ON "public"."product_subscriptions" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."global_users"
  WHERE (("global_users"."id" = "auth"."uid"()) AND ("global_users"."client_id" = "product_subscriptions"."client_id")))));



CREATE POLICY "Users can view their own access" ON "public"."client_product_access" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can view their own client" ON "public"."clients" FOR SELECT TO "authenticated" USING ((("owner_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."global_users"
  WHERE (("global_users"."id" = "auth"."uid"()) AND ("global_users"."client_id" = "clients"."id"))))));



CREATE POLICY "Users can view their own profile" ON "public"."global_users" TO "authenticated" USING (("id" = "auth"."uid"()));



ALTER TABLE "public"."client_product_access" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."clients" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."global_users" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."product_subscriptions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."product_usage_stats" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Tenant admins can insert tenant settings" ON "sms_gateway"."tenant_settings" FOR INSERT WITH CHECK ((( SELECT "count"(*) AS "count"
   FROM "sms_gateway"."tenant_members"
  WHERE (("tenant_members"."tenant_id" = "tenant_settings"."tenant_id") AND ("tenant_members"."user_id" = "auth"."uid"()) AND ("tenant_members"."role" = ANY (ARRAY['admin'::"text", 'owner'::"text"])))) > 0));



CREATE POLICY "Tenant admins can update tenant settings" ON "sms_gateway"."tenant_settings" FOR UPDATE USING (("tenant_id" IN ( SELECT "tenant_members"."tenant_id"
   FROM "sms_gateway"."tenant_members"
  WHERE (("tenant_members"."user_id" = "auth"."uid"()) AND ("tenant_members"."role" = ANY (ARRAY['admin'::"text", 'owner'::"text"]))))));



CREATE POLICY "Tenant users can view tenant settings" ON "sms_gateway"."tenant_settings" FOR SELECT USING (("tenant_id" IN ( SELECT "tenant_members"."tenant_id"
   FROM "sms_gateway"."tenant_members"
  WHERE ("tenant_members"."user_id" = "auth"."uid"()))));



CREATE POLICY "Users can delete own api_keys" ON "sms_gateway"."api_keys" FOR DELETE USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can delete own tenant sms_requests" ON "sms_gateway"."sms_requests" FOR DELETE USING (("tenant_id" IN ( SELECT "users"."tenant_id"
   FROM "sms_gateway"."users"
  WHERE ("users"."id" = "auth"."uid"()))));



CREATE POLICY "Users can delete their own contacts" ON "sms_gateway"."contacts" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own groups" ON "sms_gateway"."groups" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert own api_keys" ON "sms_gateway"."api_keys" FOR INSERT WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can insert own settings" ON "sms_gateway"."user_settings" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert sms_requests" ON "sms_gateway"."sms_requests" FOR INSERT WITH CHECK (("tenant_id" IN ( SELECT "users"."tenant_id"
   FROM "sms_gateway"."users"
  WHERE ("users"."id" = "auth"."uid"()))));



CREATE POLICY "Users can insert their own contacts" ON "sms_gateway"."contacts" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own groups" ON "sms_gateway"."groups" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own sms logs" ON "sms_gateway"."sms_logs" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage group members" ON "sms_gateway"."group_members" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "sms_gateway"."groups"
  WHERE (("groups"."id" = "group_members"."group_id") AND ("groups"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can manage own contacts" ON "sms_gateway"."contacts" USING (("user_id" = "auth"."uid"())) WITH CHECK (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can manage own profile" ON "sms_gateway"."users" TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id")) WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Users can update own api_keys" ON "sms_gateway"."api_keys" FOR UPDATE USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can update own settings" ON "sms_gateway"."user_settings" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update own tenant sms_requests" ON "sms_gateway"."sms_requests" FOR UPDATE USING (("tenant_id" IN ( SELECT "users"."tenant_id"
   FROM "sms_gateway"."users"
  WHERE ("users"."id" = "auth"."uid"()))));



CREATE POLICY "Users can update their own contacts" ON "sms_gateway"."contacts" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own groups" ON "sms_gateway"."groups" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "sms_gateway"."users" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Users can view group members" ON "sms_gateway"."group_members" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "sms_gateway"."groups"
  WHERE (("groups"."id" = "group_members"."group_id") AND ("groups"."user_id" = "auth"."uid"())))));



CREATE POLICY "Users can view own settings" ON "sms_gateway"."user_settings" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view own sync logs" ON "sms_gateway"."settings_sync_log" FOR SELECT USING ((("auth"."uid"() = "user_id") OR ("tenant_id" IN ( SELECT "tenant_members"."tenant_id"
   FROM "sms_gateway"."tenant_members"
  WHERE (("tenant_members"."user_id" = "auth"."uid"()) AND ("tenant_members"."role" = ANY (ARRAY['admin'::"text", 'owner'::"text"])))))));



CREATE POLICY "Users can view own tenant api_keys" ON "sms_gateway"."api_keys" FOR SELECT USING (("user_id" = "auth"."uid"()));



CREATE POLICY "Users can view own tenant sms_requests" ON "sms_gateway"."sms_requests" FOR SELECT USING (("tenant_id" IN ( SELECT "users"."tenant_id"
   FROM "sms_gateway"."users"
  WHERE ("users"."id" = "auth"."uid"()))));



CREATE POLICY "Users can view their own contacts" ON "sms_gateway"."contacts" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own groups" ON "sms_gateway"."groups" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own profile" ON "sms_gateway"."users" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can view their own sms logs" ON "sms_gateway"."sms_logs" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



ALTER TABLE "sms_gateway"."api_keys" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."audit_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."contacts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."group_members" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."groups" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."settings_sync_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."sms_logs" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."sms_requests" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."tenant_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."user_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "sms_gateway"."users" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "inventorymaster" TO "authenticated";
GRANT USAGE ON SCHEMA "inventorymaster" TO "service_role";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT USAGE ON SCHEMA "smartmenu" TO "authenticated";
GRANT USAGE ON SCHEMA "smartmenu" TO "service_role";



GRANT USAGE ON SCHEMA "sms_gateway" TO "anon";
GRANT USAGE ON SCHEMA "sms_gateway" TO "authenticated";
GRANT USAGE ON SCHEMA "sms_gateway" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."add_user_to_client_product"("p_user_id" "uuid", "p_client_id" "uuid", "p_product_schema" "text", "p_tenant_id" "uuid", "p_role" "text", "p_user_email" "text", "p_user_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."add_user_to_client_product"("p_user_id" "uuid", "p_client_id" "uuid", "p_product_schema" "text", "p_tenant_id" "uuid", "p_role" "text", "p_user_email" "text", "p_user_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_user_to_client_product"("p_user_id" "uuid", "p_client_id" "uuid", "p_product_schema" "text", "p_tenant_id" "uuid", "p_role" "text", "p_user_email" "text", "p_user_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_client"("p_owner_id" "uuid", "p_client_name" "text", "p_client_slug" "text", "p_client_email" "text", "p_owner_name" "text", "p_owner_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_client"("p_owner_id" "uuid", "p_client_name" "text", "p_client_slug" "text", "p_client_email" "text", "p_owner_name" "text", "p_owner_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_client"("p_owner_id" "uuid", "p_client_name" "text", "p_client_slug" "text", "p_client_email" "text", "p_owner_name" "text", "p_owner_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_type"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_type"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_type"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_user_type"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_user_type"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_user_type"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_super_admin"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_super_admin"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_super_admin"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."log_usage"("p_product_schema" "text", "p_tenant_id" "uuid", "p_client_id" "uuid", "p_action" "text", "p_details" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."log_usage"("p_product_schema" "text", "p_tenant_id" "uuid", "p_client_id" "uuid", "p_action" "text", "p_details" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_usage"("p_product_schema" "text", "p_tenant_id" "uuid", "p_client_id" "uuid", "p_action" "text", "p_details" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."promote_to_super_admin"("user_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."promote_to_super_admin"("user_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."promote_to_super_admin"("user_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."setup_test_admin"("user_email" "text", "user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."setup_test_admin"("user_email" "text", "user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."setup_test_admin"("user_email" "text", "user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."subscribe_client_to_product"("p_client_id" "uuid", "p_product_schema" "text", "p_tenant_name" "text", "p_tenant_slug" "text", "p_plan_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."subscribe_client_to_product"("p_client_id" "uuid", "p_product_schema" "text", "p_tenant_name" "text", "p_tenant_slug" "text", "p_plan_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."subscribe_client_to_product"("p_client_id" "uuid", "p_product_schema" "text", "p_tenant_name" "text", "p_tenant_slug" "text", "p_plan_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."track_product_usage"("p_product_schema" "text", "p_client_id" "uuid", "p_tenant_id" "uuid", "p_metric_name" "text", "p_metric_value" numeric, "p_metadata" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."track_product_usage"("p_product_schema" "text", "p_client_id" "uuid", "p_tenant_id" "uuid", "p_metric_name" "text", "p_metric_value" numeric, "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."track_product_usage"("p_product_schema" "text", "p_client_id" "uuid", "p_tenant_id" "uuid", "p_metric_name" "text", "p_metric_value" numeric, "p_metadata" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_set_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_set_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_set_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_type"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_type"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_type"() TO "service_role";



GRANT ALL ON FUNCTION "sms_gateway"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "sms_gateway"."get_sms_request_status"("p_api_key" "text", "p_request_id" "uuid") TO "anon";



GRANT ALL ON FUNCTION "sms_gateway"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "sms_gateway"."submit_bulk_sms_request"("p_api_key" "text", "p_phone_numbers" "text"[], "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "anon";



GRANT ALL ON FUNCTION "sms_gateway"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "sms_gateway"."submit_sms_request"("p_api_key" "text", "p_phone_number" "text", "p_message" "text", "p_external_id" "text", "p_priority" integer, "p_scheduled_at" timestamp with time zone, "p_metadata" "jsonb") TO "anon";



GRANT ALL ON FUNCTION "sms_gateway"."validate_api_key"("p_api_key" "text") TO "authenticated";


















GRANT ALL ON TABLE "inventorymaster"."inventories" TO "service_role";
GRANT ALL ON TABLE "inventorymaster"."inventories" TO "authenticated";



GRANT ALL ON TABLE "inventorymaster"."profiles" TO "service_role";
GRANT ALL ON TABLE "inventorymaster"."profiles" TO "authenticated";



GRANT ALL ON TABLE "inventorymaster"."sales" TO "service_role";
GRANT ALL ON TABLE "inventorymaster"."sales" TO "authenticated";



GRANT ALL ON TABLE "inventorymaster"."tenants" TO "service_role";
GRANT ALL ON TABLE "inventorymaster"."tenants" TO "authenticated";



GRANT ALL ON TABLE "public"."client_product_access" TO "anon";
GRANT ALL ON TABLE "public"."client_product_access" TO "authenticated";
GRANT ALL ON TABLE "public"."client_product_access" TO "service_role";



GRANT ALL ON TABLE "public"."clients" TO "anon";
GRANT ALL ON TABLE "public"."clients" TO "authenticated";
GRANT ALL ON TABLE "public"."clients" TO "service_role";



GRANT ALL ON TABLE "public"."global_users" TO "anon";
GRANT ALL ON TABLE "public"."global_users" TO "authenticated";
GRANT ALL ON TABLE "public"."global_users" TO "service_role";



GRANT ALL ON TABLE "public"."product_subscriptions" TO "anon";
GRANT ALL ON TABLE "public"."product_subscriptions" TO "authenticated";
GRANT ALL ON TABLE "public"."product_subscriptions" TO "service_role";



GRANT ALL ON TABLE "public"."product_usage_stats" TO "anon";
GRANT ALL ON TABLE "public"."product_usage_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."product_usage_stats" TO "service_role";



GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";



GRANT ALL ON TABLE "public"."v_client_overview" TO "anon";
GRANT ALL ON TABLE "public"."v_client_overview" TO "authenticated";
GRANT ALL ON TABLE "public"."v_client_overview" TO "service_role";



GRANT ALL ON TABLE "public"."v_product_overview" TO "anon";
GRANT ALL ON TABLE "public"."v_product_overview" TO "authenticated";
GRANT ALL ON TABLE "public"."v_product_overview" TO "service_role";



GRANT ALL ON TABLE "public"."v_subscription_summary" TO "anon";
GRANT ALL ON TABLE "public"."v_subscription_summary" TO "authenticated";
GRANT ALL ON TABLE "public"."v_subscription_summary" TO "service_role";



GRANT ALL ON TABLE "public"."v_user_access_overview" TO "anon";
GRANT ALL ON TABLE "public"."v_user_access_overview" TO "authenticated";
GRANT ALL ON TABLE "public"."v_user_access_overview" TO "service_role";



GRANT ALL ON TABLE "smartmenu"."profiles" TO "service_role";
GRANT ALL ON TABLE "smartmenu"."profiles" TO "authenticated";



GRANT ALL ON TABLE "smartmenu"."tenants" TO "service_role";
GRANT ALL ON TABLE "smartmenu"."tenants" TO "authenticated";



GRANT ALL ON TABLE "sms_gateway"."api_keys" TO "authenticated";
GRANT SELECT ON TABLE "sms_gateway"."api_keys" TO "anon";



GRANT SELECT ON TABLE "sms_gateway"."api_rate_limits" TO "anon";
GRANT ALL ON TABLE "sms_gateway"."api_rate_limits" TO "authenticated";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."audit_logs" TO "authenticated";
GRANT SELECT ON TABLE "sms_gateway"."audit_logs" TO "anon";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."contacts" TO "authenticated";
GRANT SELECT ON TABLE "sms_gateway"."contacts" TO "anon";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."group_members" TO "authenticated";
GRANT SELECT ON TABLE "sms_gateway"."group_members" TO "anon";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."groups" TO "authenticated";
GRANT SELECT ON TABLE "sms_gateway"."groups" TO "anon";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."settings" TO "authenticated";
GRANT SELECT ON TABLE "sms_gateway"."settings" TO "anon";



GRANT SELECT ON TABLE "sms_gateway"."settings_sync_log" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."settings_sync_log" TO "authenticated";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."sms_logs" TO "authenticated";
GRANT SELECT ON TABLE "sms_gateway"."sms_logs" TO "anon";



GRANT SELECT ON TABLE "sms_gateway"."sms_requests" TO "anon";
GRANT ALL ON TABLE "sms_gateway"."sms_requests" TO "authenticated";



GRANT SELECT ON TABLE "sms_gateway"."tenant_members" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."tenant_members" TO "authenticated";



GRANT SELECT ON TABLE "sms_gateway"."tenant_settings" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."tenant_settings" TO "authenticated";



GRANT SELECT ON TABLE "sms_gateway"."tenants" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."tenants" TO "authenticated";



GRANT SELECT ON TABLE "sms_gateway"."user_settings" TO "anon";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."user_settings" TO "authenticated";



GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "sms_gateway"."users" TO "authenticated";
GRANT SELECT ON TABLE "sms_gateway"."users" TO "anon";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "sms_gateway" GRANT SELECT ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "sms_gateway" GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES  TO "authenticated";



























drop extension if exists "pg_net";

alter table "sms_gateway"."sms_requests" drop constraint "sms_requests_status_check";

alter table "sms_gateway"."sms_requests" add constraint "sms_requests_status_check" CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'sent'::character varying, 'failed'::character varying, 'cancelled'::character varying])::text[]))) not valid;

alter table "sms_gateway"."sms_requests" validate constraint "sms_requests_status_check";


  create policy "Allow users to read their own metadata"
  on "auth"."users"
  as permissive
  for select
  to authenticated
using ((auth.uid() = id));



  create policy "Allow authenticated uploads"
  on "storage"."objects"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Allow owner delete for product-images"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'product-images'::text) AND (owner_id = (( SELECT auth.uid() AS uid))::text)));



  create policy "Allow owner update for product-images"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'product-images'::text) AND (owner_id = (( SELECT auth.uid() AS uid))::text)));



  create policy "all access 16wiy3a_0"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'product-images'::text));



  create policy "all access 16wiy3a_1"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check ((bucket_id = 'product-images'::text));



  create policy "all access 16wiy3a_2"
  on "storage"."objects"
  as permissive
  for update
  to public
using ((bucket_id = 'product-images'::text));



  create policy "all access 16wiy3a_3"
  on "storage"."objects"
  as permissive
  for delete
  to public
using ((bucket_id = 'product-images'::text));



