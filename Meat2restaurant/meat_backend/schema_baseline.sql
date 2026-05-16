--
-- PostgreSQL database dump
--

\restrict eCRIsbzid1Tvn2FaJSmpkfvU1U1QcRSjUeOoEFDYF0oR8ILq6rZyJFbFVLB7VSc

-- Dumped from database version 17.8 (6108b59)
-- Dumped by pg_dump version 17.8 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: neondb_owner
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO neondb_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: neondb_owner
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: about_store; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.about_store (
    id integer NOT NULL,
    "values" json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    company_description text,
    mission_statement text,
    vision_statement text,
    company_image_url character varying(500),
    is_current boolean,
    updated_by integer
);


ALTER TABLE public.about_store OWNER TO neondb_owner;

--
-- Name: about_store_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.about_store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.about_store_id_seq OWNER TO neondb_owner;

--
-- Name: about_store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.about_store_id_seq OWNED BY public.about_store.id;


--
-- Name: about_store_versions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.about_store_versions (
    id integer NOT NULL,
    about_store_id integer,
    version_number integer,
    company_description text,
    mission_statement text,
    vision_statement text,
    "values" json,
    created_by integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.about_store_versions OWNER TO neondb_owner;

--
-- Name: about_store_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.about_store_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.about_store_versions_id_seq OWNER TO neondb_owner;

--
-- Name: about_store_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.about_store_versions_id_seq OWNED BY public.about_store_versions.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO neondb_owner;

--
-- Name: attribute_values; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.attribute_values (
    id integer NOT NULL,
    attribute_id integer,
    value character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.attribute_values OWNER TO neondb_owner;

--
-- Name: attribute_values_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.attribute_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attribute_values_id_seq OWNER TO neondb_owner;

--
-- Name: attribute_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.attribute_values_id_seq OWNED BY public.attribute_values.id;


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.attributes (
    id integer NOT NULL,
    name character varying,
    is_active boolean,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.attributes OWNER TO neondb_owner;

--
-- Name: attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attributes_id_seq OWNER TO neondb_owner;

--
-- Name: attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.attributes_id_seq OWNED BY public.attributes.id;


--
-- Name: awards; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.awards (
    id integer NOT NULL,
    about_us_id integer,
    award_name character varying(255),
    organization character varying(255),
    award_date timestamp without time zone,
    award_image_url character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.awards OWNER TO neondb_owner;

--
-- Name: awards_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.awards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.awards_id_seq OWNER TO neondb_owner;

--
-- Name: awards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.awards_id_seq OWNED BY public.awards.id;


--
-- Name: blog_analytics; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.blog_analytics (
    id integer NOT NULL,
    post_id integer,
    viewed_at timestamp without time zone,
    viewer_id character varying(255),
    time_on_page integer,
    referrer_url character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.blog_analytics OWNER TO neondb_owner;

--
-- Name: blog_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.blog_analytics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.blog_analytics_id_seq OWNER TO neondb_owner;

--
-- Name: blog_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.blog_analytics_id_seq OWNED BY public.blog_analytics.id;


--
-- Name: blog_comments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.blog_comments (
    id integer NOT NULL,
    post_id integer,
    comment_text text,
    commenter_name character varying(255),
    commenter_email character varying(255),
    status character varying(50),
    is_approved boolean,
    approved_at timestamp without time zone,
    approved_by integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.blog_comments OWNER TO neondb_owner;

--
-- Name: blog_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.blog_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.blog_comments_id_seq OWNER TO neondb_owner;

--
-- Name: blog_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.blog_comments_id_seq OWNED BY public.blog_comments.id;


--
-- Name: blog_post_versions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.blog_post_versions (
    id integer NOT NULL,
    post_id integer,
    version_number integer,
    content text,
    status character varying(50),
    created_by integer,
    restored_from integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.blog_post_versions OWNER TO neondb_owner;

--
-- Name: blog_post_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.blog_post_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.blog_post_versions_id_seq OWNER TO neondb_owner;

--
-- Name: blog_post_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.blog_post_versions_id_seq OWNED BY public.blog_post_versions.id;


--
-- Name: blog_posts; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.blog_posts (
    id integer NOT NULL,
    title character varying,
    slug character varying,
    content text,
    author_id integer,
    is_published boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    meta_title character varying(255),
    meta_description character varying(500),
    category character varying(100),
    tags character varying(255),
    excerpt character varying(500),
    status character varying(50),
    featured_image_url character varying(500),
    scheduled_publish_at timestamp without time zone,
    published_at timestamp without time zone,
    view_count integer,
    meta_keywords character varying(500),
    is_deleted boolean,
    allow_comments boolean,
    is_featured boolean
);


ALTER TABLE public.blog_posts OWNER TO neondb_owner;

--
-- Name: blog_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.blog_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.blog_posts_id_seq OWNER TO neondb_owner;

--
-- Name: blog_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.blog_posts_id_seq OWNED BY public.blog_posts.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying,
    description character varying,
    parent_id integer,
    is_active boolean,
    image_url character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.categories OWNER TO neondb_owner;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO neondb_owner;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: certifications; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.certifications (
    id integer NOT NULL,
    about_us_id integer,
    cert_name character varying(255),
    cert_body character varying(255),
    cert_image_url character varying(500),
    issue_date timestamp without time zone,
    expiration_date timestamp without time zone,
    cert_url character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.certifications OWNER TO neondb_owner;

--
-- Name: certifications_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.certifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.certifications_id_seq OWNER TO neondb_owner;

--
-- Name: certifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.certifications_id_seq OWNED BY public.certifications.id;


--
-- Name: cms_audit_logs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.cms_audit_logs (
    id integer NOT NULL,
    action character varying(100),
    content_type character varying(50),
    content_id integer,
    admin_id integer,
    "timestamp" timestamp without time zone,
    description text,
    old_value text,
    new_value text,
    ip_address character varying(50),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.cms_audit_logs OWNER TO neondb_owner;

--
-- Name: cms_audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.cms_audit_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cms_audit_logs_id_seq OWNER TO neondb_owner;

--
-- Name: cms_audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.cms_audit_logs_id_seq OWNED BY public.cms_audit_logs.id;


--
-- Name: cms_content_tags; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.cms_content_tags (
    id integer NOT NULL,
    content_id integer,
    content_type character varying(50),
    tag_name character varying(100),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.cms_content_tags OWNER TO neondb_owner;

--
-- Name: cms_content_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.cms_content_tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cms_content_tags_id_seq OWNER TO neondb_owner;

--
-- Name: cms_content_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.cms_content_tags_id_seq OWNED BY public.cms_content_tags.id;


--
-- Name: combined_invoices; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.combined_invoices (
    id integer NOT NULL,
    customer_id integer,
    invoice_date timestamp without time zone,
    total_amount double precision NOT NULL,
    status character varying(50),
    pdf_url character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    due_date timestamp without time zone,
    discount_percentage double precision,
    discount_amount double precision,
    subtotal double precision,
    tax_total double precision
);


ALTER TABLE public.combined_invoices OWNER TO neondb_owner;

--
-- Name: combined_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.combined_invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.combined_invoices_id_seq OWNER TO neondb_owner;

--
-- Name: combined_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.combined_invoices_id_seq OWNED BY public.combined_invoices.id;


--
-- Name: configurations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.configurations (
    id integer NOT NULL,
    key character varying,
    value character varying,
    description character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.configurations OWNER TO neondb_owner;

--
-- Name: configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.configurations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.configurations_id_seq OWNER TO neondb_owner;

--
-- Name: configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.configurations_id_seq OWNED BY public.configurations.id;


--
-- Name: credit_notes; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.credit_notes (
    id integer NOT NULL,
    customer_id integer,
    invoice_id integer,
    amount double precision NOT NULL,
    reason text,
    status character varying(50),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.credit_notes OWNER TO neondb_owner;

--
-- Name: credit_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.credit_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.credit_notes_id_seq OWNER TO neondb_owner;

--
-- Name: credit_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.credit_notes_id_seq OWNED BY public.credit_notes.id;


--
-- Name: customer_groups; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.customer_groups (
    id integer NOT NULL,
    name character varying(100),
    description character varying(500),
    is_active boolean,
    discount_percentage double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.customer_groups OWNER TO neondb_owner;

--
-- Name: customer_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.customer_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_groups_id_seq OWNER TO neondb_owner;

--
-- Name: customer_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.customer_groups_id_seq OWNED BY public.customer_groups.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    name character varying,
    email character varying,
    phone character varying,
    address character varying,
    customer_type character varying,
    billing_cycle character varying,
    stripe_customer_id character varying,
    credit_limit double precision,
    current_balance double precision,
    is_verified boolean,
    business_name character varying,
    tax_id character varying,
    business_description text,
    status character varying(50),
    hashed_password character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    otp_code character varying(10),
    otp_expiry timestamp without time zone,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    wallet_balance double precision DEFAULT '0'::double precision,
    owner_name character varying(255),
    last_combined_invoice_date date,
    wallet_enabled boolean,
    cycle_start_day integer,
    cycle_cutoff_day integer,
    payment_due_day integer,
    group_id integer
);


ALTER TABLE public.customers OWNER TO neondb_owner;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO neondb_owner;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: delivery_zones; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.delivery_zones (
    id integer NOT NULL,
    name character varying,
    zip_codes text,
    fee double precision,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.delivery_zones OWNER TO neondb_owner;

--
-- Name: delivery_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.delivery_zones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.delivery_zones_id_seq OWNER TO neondb_owner;

--
-- Name: delivery_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.delivery_zones_id_seq OWNED BY public.delivery_zones.id;


--
-- Name: faq_analytics; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.faq_analytics (
    id integer NOT NULL,
    faq_id integer,
    viewed_at timestamp without time zone,
    viewer_id character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.faq_analytics OWNER TO neondb_owner;

--
-- Name: faq_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.faq_analytics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.faq_analytics_id_seq OWNER TO neondb_owner;

--
-- Name: faq_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.faq_analytics_id_seq OWNED BY public.faq_analytics.id;


--
-- Name: faq_versions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.faq_versions (
    id integer NOT NULL,
    faq_id integer,
    version_number integer,
    answer text,
    status character varying(50),
    created_by integer,
    restored_from integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.faq_versions OWNER TO neondb_owner;

--
-- Name: faq_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.faq_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.faq_versions_id_seq OWNER TO neondb_owner;

--
-- Name: faq_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.faq_versions_id_seq OWNED BY public.faq_versions.id;


--
-- Name: faq_votes; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.faq_votes (
    id integer NOT NULL,
    faq_id integer,
    voter_id character varying(255),
    vote_type character varying(50),
    voted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.faq_votes OWNER TO neondb_owner;

--
-- Name: faq_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.faq_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.faq_votes_id_seq OWNER TO neondb_owner;

--
-- Name: faq_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.faq_votes_id_seq OWNED BY public.faq_votes.id;


--
-- Name: faqs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.faqs (
    id integer NOT NULL,
    question character varying(500),
    answer text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category character varying(100),
    display_order integer,
    status character varying(50),
    is_featured boolean,
    helpful_count integer,
    unhelpful_count integer,
    helpful_percentage double precision,
    view_count integer,
    is_deleted boolean,
    tags character varying(255),
    meta_title character varying(255),
    meta_description character varying(500)
);


ALTER TABLE public.faqs OWNER TO neondb_owner;

--
-- Name: faqs_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.faqs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.faqs_id_seq OWNER TO neondb_owner;

--
-- Name: faqs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.faqs_id_seq OWNED BY public.faqs.id;


--
-- Name: gift_cards; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.gift_cards (
    id integer NOT NULL,
    code character varying,
    initial_amount double precision,
    current_balance double precision,
    is_active boolean,
    expiry_date timestamp without time zone,
    customer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.gift_cards OWNER TO neondb_owner;

--
-- Name: gift_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.gift_cards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.gift_cards_id_seq OWNER TO neondb_owner;

--
-- Name: gift_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.gift_cards_id_seq OWNED BY public.gift_cards.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    customer_id integer,
    order_id integer,
    amount_due double precision NOT NULL,
    due_date timestamp without time zone NOT NULL,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    pdf_url character varying,
    stripe_invoice_id character varying,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    combined_invoice_id integer,
    discount_percentage double precision,
    discount_amount double precision,
    subtotal double precision,
    tax_total double precision,
    invoice_date timestamp without time zone,
    terms character varying(100),
    subject character varying(500),
    salesperson_id integer,
    notes text
);


ALTER TABLE public.invoices OWNER TO neondb_owner;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoices_id_seq OWNER TO neondb_owner;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: legal_document_versions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.legal_document_versions (
    id integer NOT NULL,
    document_id integer,
    version_number integer,
    content text,
    status character varying(50),
    created_by integer,
    effective_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.legal_document_versions OWNER TO neondb_owner;

--
-- Name: legal_document_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.legal_document_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.legal_document_versions_id_seq OWNER TO neondb_owner;

--
-- Name: legal_document_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.legal_document_versions_id_seq OWNED BY public.legal_document_versions.id;


--
-- Name: legal_documents; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.legal_documents (
    id integer NOT NULL,
    content text,
    effective_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    document_type character varying(100),
    version_number integer,
    status character varying(50),
    is_current boolean,
    scheduled_effective_date timestamp without time zone,
    published_at timestamp without time zone,
    published_by integer
);


ALTER TABLE public.legal_documents OWNER TO neondb_owner;

--
-- Name: legal_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.legal_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.legal_documents_id_seq OWNER TO neondb_owner;

--
-- Name: legal_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.legal_documents_id_seq OWNED BY public.legal_documents.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    name character varying,
    address character varying,
    city character varying,
    state character varying,
    zip_code character varying,
    phone character varying,
    is_active boolean,
    created_at timestamp without time zone NOT NULL,
    is_default boolean,
    customer_id integer,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.locations OWNER TO neondb_owner;

--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locations_id_seq OWNER TO neondb_owner;

--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: membership_plans; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.membership_plans (
    id integer NOT NULL,
    name character varying,
    price integer,
    duration_days integer,
    benefits text,
    description character varying(500),
    is_active boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.membership_plans OWNER TO neondb_owner;

--
-- Name: membership_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.membership_plans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.membership_plans_id_seq OWNER TO neondb_owner;

--
-- Name: membership_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.membership_plans_id_seq OWNED BY public.membership_plans.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.memberships (
    id integer NOT NULL,
    customer_id integer,
    plan_id integer,
    start_date date,
    end_date date,
    is_active boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.memberships OWNER TO neondb_owner;

--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.memberships_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.memberships_id_seq OWNER TO neondb_owner;

--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.memberships_id_seq OWNED BY public.memberships.id;


--
-- Name: menus; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.menus (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    path character varying(500),
    icon character varying(100),
    parent_id integer,
    sort_order integer,
    is_active boolean,
    required_permission character varying(100),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.menus OWNER TO neondb_owner;

--
-- Name: menus_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.menus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menus_id_seq OWNER TO neondb_owner;

--
-- Name: menus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.menus_id_seq OWNED BY public.menus.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    customer_id integer,
    title character varying(255),
    message character varying(500),
    type character varying(50),
    payload json,
    is_read boolean DEFAULT false,
    is_delivered boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO neondb_owner;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO neondb_owner;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer,
    product_id integer,
    quantity integer NOT NULL,
    unit_price double precision NOT NULL,
    total_price double precision NOT NULL,
    variant_id integer,
    notes character varying(500)
);


ALTER TABLE public.order_items OWNER TO neondb_owner;

--
-- Name: order_status_updates; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.order_status_updates (
    id integer NOT NULL,
    order_id integer,
    old_status character varying,
    new_status character varying,
    changed_at timestamp without time zone,
    changed_by_id integer,
    notes character varying
);


ALTER TABLE public.order_status_updates OWNER TO neondb_owner;

--
-- Name: orderitems_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.orderitems_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orderitems_id_seq OWNER TO neondb_owner;

--
-- Name: orderitems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.orderitems_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    customer_id integer,
    total_amount double precision NOT NULL,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    payment_status character varying,
    notes character varying,
    location_id integer,
    payment_terms character varying,
    po_number character varying,
    promotion_id integer,
    discount_amount double precision,
    wallet_amount_used double precision DEFAULT '0'::double precision,
    delivery_otp character varying(4),
    delivery_fee double precision DEFAULT '0'::double precision,
    platform_fee double precision DEFAULT '0'::double precision
);


ALTER TABLE public.orders OWNER TO neondb_owner;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO neondb_owner;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: orderstatusupdates_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.orderstatusupdates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orderstatusupdates_id_seq OWNER TO neondb_owner;

--
-- Name: orderstatusupdates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.orderstatusupdates_id_seq OWNED BY public.order_status_updates.id;


--
-- Name: page_analytics; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.page_analytics (
    id integer NOT NULL,
    page_id integer,
    viewed_at timestamp without time zone,
    viewer_id character varying(255),
    time_on_page integer,
    referrer_url character varying(500),
    device_type character varying(50),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.page_analytics OWNER TO neondb_owner;

--
-- Name: page_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.page_analytics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.page_analytics_id_seq OWNER TO neondb_owner;

--
-- Name: page_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.page_analytics_id_seq OWNED BY public.page_analytics.id;


--
-- Name: partner_prices; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.partner_prices (
    id integer NOT NULL,
    partner_id integer NOT NULL,
    product_id integer NOT NULL,
    custom_price double precision NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.partner_prices OWNER TO neondb_owner;

--
-- Name: partner_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.partner_prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.partner_prices_id_seq OWNER TO neondb_owner;

--
-- Name: partner_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.partner_prices_id_seq OWNED BY public.partner_prices.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    customer_id integer,
    combined_invoice_id integer,
    amount double precision NOT NULL,
    payment_method character varying(50) NOT NULL,
    reference_id character varying(255),
    payment_date timestamp without time zone,
    status character varying(50),
    notes text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    invoice_id integer
);


ALTER TABLE public.payments OWNER TO neondb_owner;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO neondb_owner;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.product_variants (
    id integer NOT NULL,
    product_id integer,
    sku character varying(100),
    name character varying(255),
    price double precision,
    wholesale_price double precision,
    stock_quantity integer,
    is_active boolean,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.product_variants OWNER TO neondb_owner;

--
-- Name: product_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.product_variants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_variants_id_seq OWNER TO neondb_owner;

--
-- Name: product_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.product_variants_id_seq OWNED BY public.product_variants.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name character varying NOT NULL,
    description text,
    price double precision NOT NULL,
    sku character varying,
    image_url character varying,
    stock_quantity integer,
    is_active boolean,
    category character varying,
    category_id integer,
    wholesale_price double precision,
    unit character varying,
    min_order_quantity integer,
    volume_tiers json,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.products OWNER TO neondb_owner;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_id_seq OWNER TO neondb_owner;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: promotions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.promotions (
    id integer NOT NULL,
    name character varying,
    code character varying,
    description character varying,
    discount_type character varying,
    discount_value double precision,
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    is_active boolean,
    usage_limit integer,
    usage_count integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    banner_url character varying(500),
    target_type character varying(50),
    target_id integer
);


ALTER TABLE public.promotions OWNER TO neondb_owner;

--
-- Name: promotions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.promotions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promotions_id_seq OWNER TO neondb_owner;

--
-- Name: promotions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.promotions_id_seq OWNED BY public.promotions.id;


--
-- Name: recipe_analytics; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.recipe_analytics (
    id integer NOT NULL,
    recipe_id integer,
    viewed_at timestamp without time zone,
    viewer_id character varying(255),
    time_on_page integer,
    product_clicked integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.recipe_analytics OWNER TO neondb_owner;

--
-- Name: recipe_analytics_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.recipe_analytics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipe_analytics_id_seq OWNER TO neondb_owner;

--
-- Name: recipe_analytics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.recipe_analytics_id_seq OWNED BY public.recipe_analytics.id;


--
-- Name: recipe_ingredients; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.recipe_ingredients (
    id integer NOT NULL,
    recipe_id integer,
    ingredient_name character varying(255),
    quantity double precision,
    unit character varying(50),
    sort_order integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.recipe_ingredients OWNER TO neondb_owner;

--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.recipe_ingredients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipe_ingredients_id_seq OWNER TO neondb_owner;

--
-- Name: recipe_ingredients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.recipe_ingredients_id_seq OWNED BY public.recipe_ingredients.id;


--
-- Name: recipe_nutrition; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.recipe_nutrition (
    id integer NOT NULL,
    recipe_id integer,
    calories integer,
    protein_g double precision,
    carbs_g double precision,
    fats_g double precision,
    fiber_g double precision,
    sodium_mg double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.recipe_nutrition OWNER TO neondb_owner;

--
-- Name: recipe_nutrition_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.recipe_nutrition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipe_nutrition_id_seq OWNER TO neondb_owner;

--
-- Name: recipe_nutrition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.recipe_nutrition_id_seq OWNED BY public.recipe_nutrition.id;


--
-- Name: recipe_reviews; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.recipe_reviews (
    id integer NOT NULL,
    recipe_id integer,
    customer_id integer,
    customer_name character varying(255),
    rating integer,
    review_text text,
    status character varying(50),
    is_approved boolean,
    approved_at timestamp without time zone,
    helpful_count integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.recipe_reviews OWNER TO neondb_owner;

--
-- Name: recipe_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.recipe_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipe_reviews_id_seq OWNER TO neondb_owner;

--
-- Name: recipe_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.recipe_reviews_id_seq OWNED BY public.recipe_reviews.id;


--
-- Name: recipe_steps; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.recipe_steps (
    id integer NOT NULL,
    recipe_id integer,
    step_number integer,
    step_title character varying(255),
    step_description text,
    time_in_minutes integer,
    step_image_url character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.recipe_steps OWNER TO neondb_owner;

--
-- Name: recipe_steps_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.recipe_steps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipe_steps_id_seq OWNER TO neondb_owner;

--
-- Name: recipe_steps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.recipe_steps_id_seq OWNED BY public.recipe_steps.id;


--
-- Name: recipe_versions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.recipe_versions (
    id integer NOT NULL,
    recipe_id integer,
    version_number integer,
    data_snapshot json,
    status character varying(50),
    created_by integer,
    restored_from integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.recipe_versions OWNER TO neondb_owner;

--
-- Name: recipe_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.recipe_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipe_versions_id_seq OWNER TO neondb_owner;

--
-- Name: recipe_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.recipe_versions_id_seq OWNED BY public.recipe_versions.id;


--
-- Name: recipes; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.recipes (
    id integer NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    prep_time integer,
    cook_time integer,
    meta_title character varying(255),
    meta_description character varying(500),
    slug character varying(255),
    featured_image_url character varying(500),
    cuisine_type character varying(100),
    difficulty_level character varying(50),
    meal_type character varying(100),
    total_time integer,
    servings integer,
    calories_per_serving integer,
    status character varying(50),
    is_published boolean,
    scheduled_publish_at timestamp without time zone,
    published_at timestamp without time zone,
    avg_rating double precision,
    total_reviews_count integer,
    is_deleted boolean
);


ALTER TABLE public.recipes OWNER TO neondb_owner;

--
-- Name: recipes_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.recipes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.recipes_id_seq OWNER TO neondb_owner;

--
-- Name: recipes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.recipes_id_seq OWNED BY public.recipes.id;


--
-- Name: recipes_products; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.recipes_products (
    recipe_id integer,
    product_id integer,
    quantity_needed double precision,
    unit character varying(50)
);


ALTER TABLE public.recipes_products OWNER TO neondb_owner;

--
-- Name: shipments; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.shipments (
    id integer NOT NULL,
    order_id integer,
    tracking_number character varying,
    carrier character varying,
    status character varying,
    shipped_date timestamp without time zone,
    delivered_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    driver_id integer
);


ALTER TABLE public.shipments OWNER TO neondb_owner;

--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.shipments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shipments_id_seq OWNER TO neondb_owner;

--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.shipments_id_seq OWNED BY public.shipments.id;


--
-- Name: shipping_methods; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.shipping_methods (
    id integer NOT NULL,
    name character varying,
    description character varying,
    price double precision,
    is_active boolean,
    estimated_days integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shipping_methods OWNER TO neondb_owner;

--
-- Name: shipping_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.shipping_methods_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shipping_methods_id_seq OWNER TO neondb_owner;

--
-- Name: shipping_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.shipping_methods_id_seq OWNED BY public.shipping_methods.id;


--
-- Name: tax_templates; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.tax_templates (
    id integer NOT NULL,
    name character varying,
    rate double precision,
    is_default boolean,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tax_templates OWNER TO neondb_owner;

--
-- Name: tax_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.tax_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tax_templates_id_seq OWNER TO neondb_owner;

--
-- Name: tax_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.tax_templates_id_seq OWNED BY public.tax_templates.id;


--
-- Name: team_members; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.team_members (
    id integer NOT NULL,
    name character varying(255),
    job_title character varying(255),
    email character varying(255),
    phone character varying(50),
    photo_url character varying(500),
    photo_thumbnail_url character varying(500),
    bio text,
    department character varying(100),
    linkedin_url character varying(500),
    skills json,
    is_active boolean,
    display_order integer,
    is_deleted boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.team_members OWNER TO neondb_owner;

--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.team_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.team_members_id_seq OWNER TO neondb_owner;

--
-- Name: team_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.team_members_id_seq OWNED BY public.team_members.id;


--
-- Name: test_results; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.test_results (
    id integer NOT NULL,
    test_run_id integer,
    nodeid character varying(500),
    module_code character varying(50),
    status character varying(20),
    duration double precision,
    error_message text
);


ALTER TABLE public.test_results OWNER TO neondb_owner;

--
-- Name: test_results_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.test_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.test_results_id_seq OWNER TO neondb_owner;

--
-- Name: test_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.test_results_id_seq OWNED BY public.test_results.id;


--
-- Name: test_runs; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.test_runs (
    id integer NOT NULL,
    "timestamp" timestamp without time zone,
    total_tests integer,
    passed_count integer,
    failed_count integer,
    skipped_count integer,
    duration double precision,
    environment character varying(50),
    project_code character varying(50)
);


ALTER TABLE public.test_runs OWNER TO neondb_owner;

--
-- Name: test_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.test_runs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.test_runs_id_seq OWNER TO neondb_owner;

--
-- Name: test_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.test_runs_id_seq OWNED BY public.test_runs.id;


--
-- Name: timeline_events; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.timeline_events (
    id integer NOT NULL,
    about_us_id integer,
    event_year integer,
    event_title character varying(255),
    event_description text,
    event_image_url character varying(500),
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.timeline_events OWNER TO neondb_owner;

--
-- Name: timeline_events_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.timeline_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.timeline_events_id_seq OWNER TO neondb_owner;

--
-- Name: timeline_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.timeline_events_id_seq OWNED BY public.timeline_events.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.users (
    id integer NOT NULL,
    full_name character varying,
    email character varying NOT NULL,
    hashed_password character varying NOT NULL,
    is_active boolean,
    is_superuser boolean,
    role character varying,
    permissions json,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO neondb_owner;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO neondb_owner;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: variant_attribute_values; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.variant_attribute_values (
    variant_id integer NOT NULL,
    attribute_value_id integer NOT NULL
);


ALTER TABLE public.variant_attribute_values OWNER TO neondb_owner;

--
-- Name: wallet_transactions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.wallet_transactions (
    id integer NOT NULL,
    customer_id integer,
    amount double precision NOT NULL,
    transaction_type character varying(50) NOT NULL,
    reference_id character varying(100),
    notes character varying(500),
    created_at timestamp without time zone
);


ALTER TABLE public.wallet_transactions OWNER TO neondb_owner;

--
-- Name: wallet_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.wallet_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wallet_transactions_id_seq OWNER TO neondb_owner;

--
-- Name: wallet_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.wallet_transactions_id_seq OWNED BY public.wallet_transactions.id;


--
-- Name: web_page_versions; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.web_page_versions (
    id integer NOT NULL,
    page_id integer,
    version_number integer,
    content text,
    featured_image_url character varying(500),
    status character varying(50),
    created_by integer,
    restored_from integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    meta_title character varying(255),
    meta_description character varying(500),
    meta_keywords character varying(500),
    is_homepage boolean DEFAULT false,
    visibility character varying(50) DEFAULT 'public'::character varying
);


ALTER TABLE public.web_page_versions OWNER TO neondb_owner;

--
-- Name: web_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.web_page_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.web_page_versions_id_seq OWNER TO neondb_owner;

--
-- Name: web_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.web_page_versions_id_seq OWNED BY public.web_page_versions.id;


--
-- Name: web_pages; Type: TABLE; Schema: public; Owner: neondb_owner
--

CREATE TABLE public.web_pages (
    id integer NOT NULL,
    title character varying,
    slug character varying,
    content text,
    is_published boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    meta_title character varying(255),
    meta_description character varying(500),
    sections text,
    featured_image_url character varying(500),
    status character varying(50),
    scheduled_publish_at timestamp without time zone,
    published_at timestamp without time zone,
    published_by integer,
    meta_keywords character varying(500),
    is_deleted boolean,
    is_homepage boolean DEFAULT false,
    visibility character varying(50) DEFAULT 'public'::character varying,
    password character varying(255),
    updated_by integer
);


ALTER TABLE public.web_pages OWNER TO neondb_owner;

--
-- Name: web_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: neondb_owner
--

CREATE SEQUENCE public.web_pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.web_pages_id_seq OWNER TO neondb_owner;

--
-- Name: web_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: neondb_owner
--

ALTER SEQUENCE public.web_pages_id_seq OWNED BY public.web_pages.id;


--
-- Name: about_store id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.about_store ALTER COLUMN id SET DEFAULT nextval('public.about_store_id_seq'::regclass);


--
-- Name: about_store_versions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.about_store_versions ALTER COLUMN id SET DEFAULT nextval('public.about_store_versions_id_seq'::regclass);


--
-- Name: attribute_values id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.attribute_values ALTER COLUMN id SET DEFAULT nextval('public.attribute_values_id_seq'::regclass);


--
-- Name: attributes id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.attributes ALTER COLUMN id SET DEFAULT nextval('public.attributes_id_seq'::regclass);


--
-- Name: awards id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.awards ALTER COLUMN id SET DEFAULT nextval('public.awards_id_seq'::regclass);


--
-- Name: blog_analytics id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_analytics ALTER COLUMN id SET DEFAULT nextval('public.blog_analytics_id_seq'::regclass);


--
-- Name: blog_comments id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_comments ALTER COLUMN id SET DEFAULT nextval('public.blog_comments_id_seq'::regclass);


--
-- Name: blog_post_versions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_post_versions ALTER COLUMN id SET DEFAULT nextval('public.blog_post_versions_id_seq'::regclass);


--
-- Name: blog_posts id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_posts ALTER COLUMN id SET DEFAULT nextval('public.blog_posts_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: certifications id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.certifications ALTER COLUMN id SET DEFAULT nextval('public.certifications_id_seq'::regclass);


--
-- Name: cms_audit_logs id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cms_audit_logs ALTER COLUMN id SET DEFAULT nextval('public.cms_audit_logs_id_seq'::regclass);


--
-- Name: cms_content_tags id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cms_content_tags ALTER COLUMN id SET DEFAULT nextval('public.cms_content_tags_id_seq'::regclass);


--
-- Name: combined_invoices id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.combined_invoices ALTER COLUMN id SET DEFAULT nextval('public.combined_invoices_id_seq'::regclass);


--
-- Name: configurations id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.configurations ALTER COLUMN id SET DEFAULT nextval('public.configurations_id_seq'::regclass);


--
-- Name: credit_notes id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.credit_notes ALTER COLUMN id SET DEFAULT nextval('public.credit_notes_id_seq'::regclass);


--
-- Name: customer_groups id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customer_groups ALTER COLUMN id SET DEFAULT nextval('public.customer_groups_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: delivery_zones id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.delivery_zones ALTER COLUMN id SET DEFAULT nextval('public.delivery_zones_id_seq'::regclass);


--
-- Name: faq_analytics id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_analytics ALTER COLUMN id SET DEFAULT nextval('public.faq_analytics_id_seq'::regclass);


--
-- Name: faq_versions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_versions ALTER COLUMN id SET DEFAULT nextval('public.faq_versions_id_seq'::regclass);


--
-- Name: faq_votes id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_votes ALTER COLUMN id SET DEFAULT nextval('public.faq_votes_id_seq'::regclass);


--
-- Name: faqs id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faqs ALTER COLUMN id SET DEFAULT nextval('public.faqs_id_seq'::regclass);


--
-- Name: gift_cards id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gift_cards ALTER COLUMN id SET DEFAULT nextval('public.gift_cards_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: legal_document_versions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.legal_document_versions ALTER COLUMN id SET DEFAULT nextval('public.legal_document_versions_id_seq'::regclass);


--
-- Name: legal_documents id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.legal_documents ALTER COLUMN id SET DEFAULT nextval('public.legal_documents_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: membership_plans id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.membership_plans ALTER COLUMN id SET DEFAULT nextval('public.membership_plans_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.memberships ALTER COLUMN id SET DEFAULT nextval('public.memberships_id_seq'::regclass);


--
-- Name: menus id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.menus ALTER COLUMN id SET DEFAULT nextval('public.menus_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.orderitems_id_seq'::regclass);


--
-- Name: order_status_updates id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_status_updates ALTER COLUMN id SET DEFAULT nextval('public.orderstatusupdates_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: page_analytics id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.page_analytics ALTER COLUMN id SET DEFAULT nextval('public.page_analytics_id_seq'::regclass);


--
-- Name: partner_prices id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.partner_prices ALTER COLUMN id SET DEFAULT nextval('public.partner_prices_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: product_variants id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.product_variants ALTER COLUMN id SET DEFAULT nextval('public.product_variants_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: promotions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.promotions ALTER COLUMN id SET DEFAULT nextval('public.promotions_id_seq'::regclass);


--
-- Name: recipe_analytics id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_analytics ALTER COLUMN id SET DEFAULT nextval('public.recipe_analytics_id_seq'::regclass);


--
-- Name: recipe_ingredients id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_ingredients ALTER COLUMN id SET DEFAULT nextval('public.recipe_ingredients_id_seq'::regclass);


--
-- Name: recipe_nutrition id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_nutrition ALTER COLUMN id SET DEFAULT nextval('public.recipe_nutrition_id_seq'::regclass);


--
-- Name: recipe_reviews id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_reviews ALTER COLUMN id SET DEFAULT nextval('public.recipe_reviews_id_seq'::regclass);


--
-- Name: recipe_steps id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_steps ALTER COLUMN id SET DEFAULT nextval('public.recipe_steps_id_seq'::regclass);


--
-- Name: recipe_versions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_versions ALTER COLUMN id SET DEFAULT nextval('public.recipe_versions_id_seq'::regclass);


--
-- Name: recipes id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipes ALTER COLUMN id SET DEFAULT nextval('public.recipes_id_seq'::regclass);


--
-- Name: shipments id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.shipments ALTER COLUMN id SET DEFAULT nextval('public.shipments_id_seq'::regclass);


--
-- Name: shipping_methods id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.shipping_methods ALTER COLUMN id SET DEFAULT nextval('public.shipping_methods_id_seq'::regclass);


--
-- Name: tax_templates id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.tax_templates ALTER COLUMN id SET DEFAULT nextval('public.tax_templates_id_seq'::regclass);


--
-- Name: team_members id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.team_members ALTER COLUMN id SET DEFAULT nextval('public.team_members_id_seq'::regclass);


--
-- Name: test_results id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.test_results ALTER COLUMN id SET DEFAULT nextval('public.test_results_id_seq'::regclass);


--
-- Name: test_runs id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.test_runs ALTER COLUMN id SET DEFAULT nextval('public.test_runs_id_seq'::regclass);


--
-- Name: timeline_events id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.timeline_events ALTER COLUMN id SET DEFAULT nextval('public.timeline_events_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wallet_transactions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.wallet_transactions ALTER COLUMN id SET DEFAULT nextval('public.wallet_transactions_id_seq'::regclass);


--
-- Name: web_page_versions id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.web_page_versions ALTER COLUMN id SET DEFAULT nextval('public.web_page_versions_id_seq'::regclass);


--
-- Name: web_pages id; Type: DEFAULT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.web_pages ALTER COLUMN id SET DEFAULT nextval('public.web_pages_id_seq'::regclass);


--
-- Name: about_store about_store_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.about_store
    ADD CONSTRAINT about_store_pkey PRIMARY KEY (id);


--
-- Name: about_store_versions about_store_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.about_store_versions
    ADD CONSTRAINT about_store_versions_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: attribute_values attribute_values_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.attribute_values
    ADD CONSTRAINT attribute_values_pkey PRIMARY KEY (id);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id);


--
-- Name: awards awards_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.awards
    ADD CONSTRAINT awards_pkey PRIMARY KEY (id);


--
-- Name: blog_analytics blog_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_analytics
    ADD CONSTRAINT blog_analytics_pkey PRIMARY KEY (id);


--
-- Name: blog_comments blog_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT blog_comments_pkey PRIMARY KEY (id);


--
-- Name: blog_post_versions blog_post_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_post_versions
    ADD CONSTRAINT blog_post_versions_pkey PRIMARY KEY (id);


--
-- Name: blog_posts blog_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: certifications certifications_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.certifications
    ADD CONSTRAINT certifications_pkey PRIMARY KEY (id);


--
-- Name: cms_audit_logs cms_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cms_audit_logs
    ADD CONSTRAINT cms_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: cms_content_tags cms_content_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cms_content_tags
    ADD CONSTRAINT cms_content_tags_pkey PRIMARY KEY (id);


--
-- Name: combined_invoices combined_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.combined_invoices
    ADD CONSTRAINT combined_invoices_pkey PRIMARY KEY (id);


--
-- Name: configurations configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.configurations
    ADD CONSTRAINT configurations_pkey PRIMARY KEY (id);


--
-- Name: credit_notes credit_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.credit_notes
    ADD CONSTRAINT credit_notes_pkey PRIMARY KEY (id);


--
-- Name: customer_groups customer_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customer_groups
    ADD CONSTRAINT customer_groups_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: delivery_zones delivery_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.delivery_zones
    ADD CONSTRAINT delivery_zones_pkey PRIMARY KEY (id);


--
-- Name: faq_analytics faq_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_analytics
    ADD CONSTRAINT faq_analytics_pkey PRIMARY KEY (id);


--
-- Name: faq_versions faq_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_versions
    ADD CONSTRAINT faq_versions_pkey PRIMARY KEY (id);


--
-- Name: faq_votes faq_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_votes
    ADD CONSTRAINT faq_votes_pkey PRIMARY KEY (id);


--
-- Name: faqs faqs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faqs
    ADD CONSTRAINT faqs_pkey PRIMARY KEY (id);


--
-- Name: gift_cards gift_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gift_cards
    ADD CONSTRAINT gift_cards_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: legal_document_versions legal_document_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.legal_document_versions
    ADD CONSTRAINT legal_document_versions_pkey PRIMARY KEY (id);


--
-- Name: legal_documents legal_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.legal_documents
    ADD CONSTRAINT legal_documents_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: membership_plans membership_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.membership_plans
    ADD CONSTRAINT membership_plans_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: menus menus_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_items orderitems_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT orderitems_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: order_status_updates orderstatusupdates_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_status_updates
    ADD CONSTRAINT orderstatusupdates_pkey PRIMARY KEY (id);


--
-- Name: page_analytics page_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.page_analytics
    ADD CONSTRAINT page_analytics_pkey PRIMARY KEY (id);


--
-- Name: partner_prices partner_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.partner_prices
    ADD CONSTRAINT partner_prices_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: promotions promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);


--
-- Name: recipe_analytics recipe_analytics_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_analytics
    ADD CONSTRAINT recipe_analytics_pkey PRIMARY KEY (id);


--
-- Name: recipe_ingredients recipe_ingredients_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (id);


--
-- Name: recipe_nutrition recipe_nutrition_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_nutrition
    ADD CONSTRAINT recipe_nutrition_pkey PRIMARY KEY (id);


--
-- Name: recipe_reviews recipe_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_reviews
    ADD CONSTRAINT recipe_reviews_pkey PRIMARY KEY (id);


--
-- Name: recipe_steps recipe_steps_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_steps
    ADD CONSTRAINT recipe_steps_pkey PRIMARY KEY (id);


--
-- Name: recipe_versions recipe_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_versions
    ADD CONSTRAINT recipe_versions_pkey PRIMARY KEY (id);


--
-- Name: recipes recipes_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipes
    ADD CONSTRAINT recipes_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: shipping_methods shipping_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.shipping_methods
    ADD CONSTRAINT shipping_methods_pkey PRIMARY KEY (id);


--
-- Name: tax_templates tax_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.tax_templates
    ADD CONSTRAINT tax_templates_pkey PRIMARY KEY (id);


--
-- Name: team_members team_members_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pkey PRIMARY KEY (id);


--
-- Name: test_results test_results_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.test_results
    ADD CONSTRAINT test_results_pkey PRIMARY KEY (id);


--
-- Name: test_runs test_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.test_runs
    ADD CONSTRAINT test_runs_pkey PRIMARY KEY (id);


--
-- Name: timeline_events timeline_events_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.timeline_events
    ADD CONSTRAINT timeline_events_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: variant_attribute_values variant_attribute_values_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.variant_attribute_values
    ADD CONSTRAINT variant_attribute_values_pkey PRIMARY KEY (variant_id, attribute_value_id);


--
-- Name: wallet_transactions wallet_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_pkey PRIMARY KEY (id);


--
-- Name: web_page_versions web_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.web_page_versions
    ADD CONSTRAINT web_page_versions_pkey PRIMARY KEY (id);


--
-- Name: web_pages web_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.web_pages
    ADD CONSTRAINT web_pages_pkey PRIMARY KEY (id);


--
-- Name: ix_about_store_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_about_store_created_at ON public.about_store USING btree (created_at);


--
-- Name: ix_about_store_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_about_store_id ON public.about_store USING btree (id);


--
-- Name: ix_about_store_versions_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_about_store_versions_created_at ON public.about_store_versions USING btree (created_at);


--
-- Name: ix_about_store_versions_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_about_store_versions_id ON public.about_store_versions USING btree (id);


--
-- Name: ix_attribute_values_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_attribute_values_created_at ON public.attribute_values USING btree (created_at);


--
-- Name: ix_attribute_values_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_attribute_values_id ON public.attribute_values USING btree (id);


--
-- Name: ix_attributes_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_attributes_created_at ON public.attributes USING btree (created_at);


--
-- Name: ix_attributes_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_attributes_id ON public.attributes USING btree (id);


--
-- Name: ix_attributes_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_attributes_name ON public.attributes USING btree (name);


--
-- Name: ix_awards_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_awards_created_at ON public.awards USING btree (created_at);


--
-- Name: ix_awards_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_awards_id ON public.awards USING btree (id);


--
-- Name: ix_blog_analytics_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_analytics_created_at ON public.blog_analytics USING btree (created_at);


--
-- Name: ix_blog_analytics_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_analytics_id ON public.blog_analytics USING btree (id);


--
-- Name: ix_blog_comments_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_comments_created_at ON public.blog_comments USING btree (created_at);


--
-- Name: ix_blog_comments_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_comments_id ON public.blog_comments USING btree (id);


--
-- Name: ix_blog_post_versions_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_post_versions_created_at ON public.blog_post_versions USING btree (created_at);


--
-- Name: ix_blog_post_versions_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_post_versions_id ON public.blog_post_versions USING btree (id);


--
-- Name: ix_blog_posts_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_posts_created_at ON public.blog_posts USING btree (created_at);


--
-- Name: ix_blog_posts_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_posts_id ON public.blog_posts USING btree (id);


--
-- Name: ix_blog_posts_slug; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_blog_posts_slug ON public.blog_posts USING btree (slug);


--
-- Name: ix_blog_posts_title; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_blog_posts_title ON public.blog_posts USING btree (title);


--
-- Name: ix_categories_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_categories_created_at ON public.categories USING btree (created_at);


--
-- Name: ix_categories_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_categories_id ON public.categories USING btree (id);


--
-- Name: ix_categories_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_categories_name ON public.categories USING btree (name);


--
-- Name: ix_certifications_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_certifications_created_at ON public.certifications USING btree (created_at);


--
-- Name: ix_certifications_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_certifications_id ON public.certifications USING btree (id);


--
-- Name: ix_cms_audit_logs_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_cms_audit_logs_created_at ON public.cms_audit_logs USING btree (created_at);


--
-- Name: ix_cms_audit_logs_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_cms_audit_logs_id ON public.cms_audit_logs USING btree (id);


--
-- Name: ix_cms_content_tags_content_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_cms_content_tags_content_id ON public.cms_content_tags USING btree (content_id);


--
-- Name: ix_cms_content_tags_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_cms_content_tags_created_at ON public.cms_content_tags USING btree (created_at);


--
-- Name: ix_cms_content_tags_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_cms_content_tags_id ON public.cms_content_tags USING btree (id);


--
-- Name: ix_cms_content_tags_tag_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_cms_content_tags_tag_name ON public.cms_content_tags USING btree (tag_name);


--
-- Name: ix_combined_invoices_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_combined_invoices_created_at ON public.combined_invoices USING btree (created_at);


--
-- Name: ix_combined_invoices_customer_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_combined_invoices_customer_id ON public.combined_invoices USING btree (customer_id);


--
-- Name: ix_combined_invoices_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_combined_invoices_id ON public.combined_invoices USING btree (id);


--
-- Name: ix_configurations_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_configurations_created_at ON public.configurations USING btree (created_at);


--
-- Name: ix_configurations_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_configurations_id ON public.configurations USING btree (id);


--
-- Name: ix_configurations_key; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_configurations_key ON public.configurations USING btree (key);


--
-- Name: ix_credit_notes_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_credit_notes_created_at ON public.credit_notes USING btree (created_at);


--
-- Name: ix_credit_notes_customer_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_credit_notes_customer_id ON public.credit_notes USING btree (customer_id);


--
-- Name: ix_credit_notes_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_credit_notes_id ON public.credit_notes USING btree (id);


--
-- Name: ix_credit_notes_invoice_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_credit_notes_invoice_id ON public.credit_notes USING btree (invoice_id);


--
-- Name: ix_customer_groups_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_customer_groups_created_at ON public.customer_groups USING btree (created_at);


--
-- Name: ix_customer_groups_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_customer_groups_id ON public.customer_groups USING btree (id);


--
-- Name: ix_customer_groups_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_customer_groups_name ON public.customer_groups USING btree (name);


--
-- Name: ix_customers_business_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_customers_business_name ON public.customers USING btree (business_name);


--
-- Name: ix_customers_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_customers_created_at ON public.customers USING btree (created_at);


--
-- Name: ix_customers_email; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_customers_email ON public.customers USING btree (email);


--
-- Name: ix_customers_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_customers_id ON public.customers USING btree (id);


--
-- Name: ix_customers_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_customers_name ON public.customers USING btree (name);


--
-- Name: ix_customers_phone; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_customers_phone ON public.customers USING btree (phone);


--
-- Name: ix_customers_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_customers_status ON public.customers USING btree (status);


--
-- Name: ix_delivery_zones_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_delivery_zones_created_at ON public.delivery_zones USING btree (created_at);


--
-- Name: ix_delivery_zones_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_delivery_zones_id ON public.delivery_zones USING btree (id);


--
-- Name: ix_delivery_zones_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_delivery_zones_name ON public.delivery_zones USING btree (name);


--
-- Name: ix_faq_analytics_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faq_analytics_created_at ON public.faq_analytics USING btree (created_at);


--
-- Name: ix_faq_analytics_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faq_analytics_id ON public.faq_analytics USING btree (id);


--
-- Name: ix_faq_versions_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faq_versions_created_at ON public.faq_versions USING btree (created_at);


--
-- Name: ix_faq_versions_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faq_versions_id ON public.faq_versions USING btree (id);


--
-- Name: ix_faq_votes_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faq_votes_created_at ON public.faq_votes USING btree (created_at);


--
-- Name: ix_faq_votes_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faq_votes_id ON public.faq_votes USING btree (id);


--
-- Name: ix_faqs_category; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faqs_category ON public.faqs USING btree (category);


--
-- Name: ix_faqs_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faqs_created_at ON public.faqs USING btree (created_at);


--
-- Name: ix_faqs_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faqs_id ON public.faqs USING btree (id);


--
-- Name: ix_faqs_question; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_faqs_question ON public.faqs USING btree (question);


--
-- Name: ix_gift_cards_code; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_gift_cards_code ON public.gift_cards USING btree (code);


--
-- Name: ix_gift_cards_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_gift_cards_created_at ON public.gift_cards USING btree (created_at);


--
-- Name: ix_gift_cards_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_gift_cards_id ON public.gift_cards USING btree (id);


--
-- Name: ix_invoices_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_invoices_created_at ON public.invoices USING btree (created_at);


--
-- Name: ix_invoices_customer_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_invoices_customer_id ON public.invoices USING btree (customer_id);


--
-- Name: ix_invoices_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_invoices_id ON public.invoices USING btree (id);


--
-- Name: ix_invoices_order_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_invoices_order_id ON public.invoices USING btree (order_id);


--
-- Name: ix_invoices_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_invoices_status ON public.invoices USING btree (status);


--
-- Name: ix_legal_document_versions_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_legal_document_versions_created_at ON public.legal_document_versions USING btree (created_at);


--
-- Name: ix_legal_document_versions_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_legal_document_versions_id ON public.legal_document_versions USING btree (id);


--
-- Name: ix_legal_documents_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_legal_documents_created_at ON public.legal_documents USING btree (created_at);


--
-- Name: ix_legal_documents_document_type; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_legal_documents_document_type ON public.legal_documents USING btree (document_type);


--
-- Name: ix_legal_documents_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_legal_documents_id ON public.legal_documents USING btree (id);


--
-- Name: ix_locations_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_locations_created_at ON public.locations USING btree (created_at);


--
-- Name: ix_locations_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_locations_id ON public.locations USING btree (id);


--
-- Name: ix_locations_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_locations_name ON public.locations USING btree (name);


--
-- Name: ix_membership_plans_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_membership_plans_created_at ON public.membership_plans USING btree (created_at);


--
-- Name: ix_membership_plans_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_membership_plans_id ON public.membership_plans USING btree (id);


--
-- Name: ix_membership_plans_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_membership_plans_name ON public.membership_plans USING btree (name);


--
-- Name: ix_memberships_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_memberships_created_at ON public.memberships USING btree (created_at);


--
-- Name: ix_memberships_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_memberships_id ON public.memberships USING btree (id);


--
-- Name: ix_menus_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_menus_created_at ON public.menus USING btree (created_at);


--
-- Name: ix_menus_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_menus_id ON public.menus USING btree (id);


--
-- Name: ix_menus_title; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_menus_title ON public.menus USING btree (title);


--
-- Name: ix_notifications_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_notifications_created_at ON public.notifications USING btree (created_at);


--
-- Name: ix_notifications_customer_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_notifications_customer_id ON public.notifications USING btree (customer_id);


--
-- Name: ix_notifications_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_notifications_id ON public.notifications USING btree (id);


--
-- Name: ix_order_items_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_order_items_id ON public.order_items USING btree (id);


--
-- Name: ix_order_items_order_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_order_items_order_id ON public.order_items USING btree (order_id);


--
-- Name: ix_order_status_updates_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_order_status_updates_id ON public.order_status_updates USING btree (id);


--
-- Name: ix_order_status_updates_order_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_order_status_updates_order_id ON public.order_status_updates USING btree (order_id);


--
-- Name: ix_orders_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_orders_created_at ON public.orders USING btree (created_at);


--
-- Name: ix_orders_customer_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_orders_customer_id ON public.orders USING btree (customer_id);


--
-- Name: ix_orders_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_orders_id ON public.orders USING btree (id);


--
-- Name: ix_orders_location_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_orders_location_id ON public.orders USING btree (location_id);


--
-- Name: ix_orders_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_orders_status ON public.orders USING btree (status);


--
-- Name: ix_page_analytics_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_page_analytics_created_at ON public.page_analytics USING btree (created_at);


--
-- Name: ix_page_analytics_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_page_analytics_id ON public.page_analytics USING btree (id);


--
-- Name: ix_partner_prices_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_partner_prices_created_at ON public.partner_prices USING btree (created_at);


--
-- Name: ix_partner_prices_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_partner_prices_id ON public.partner_prices USING btree (id);


--
-- Name: ix_payments_combined_invoice_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_payments_combined_invoice_id ON public.payments USING btree (combined_invoice_id);


--
-- Name: ix_payments_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_payments_created_at ON public.payments USING btree (created_at);


--
-- Name: ix_payments_customer_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_payments_customer_id ON public.payments USING btree (customer_id);


--
-- Name: ix_payments_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_payments_id ON public.payments USING btree (id);


--
-- Name: ix_payments_invoice_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_payments_invoice_id ON public.payments USING btree (invoice_id);


--
-- Name: ix_product_variants_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_product_variants_created_at ON public.product_variants USING btree (created_at);


--
-- Name: ix_product_variants_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_product_variants_id ON public.product_variants USING btree (id);


--
-- Name: ix_product_variants_sku; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_product_variants_sku ON public.product_variants USING btree (sku);


--
-- Name: ix_products_category; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_products_category ON public.products USING btree (category);


--
-- Name: ix_products_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_products_created_at ON public.products USING btree (created_at);


--
-- Name: ix_products_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_products_id ON public.products USING btree (id);


--
-- Name: ix_products_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_products_name ON public.products USING btree (name);


--
-- Name: ix_products_sku; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_products_sku ON public.products USING btree (sku);


--
-- Name: ix_products_stock_quantity; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_products_stock_quantity ON public.products USING btree (stock_quantity);


--
-- Name: ix_promotions_code; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_promotions_code ON public.promotions USING btree (code);


--
-- Name: ix_promotions_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_promotions_created_at ON public.promotions USING btree (created_at);


--
-- Name: ix_promotions_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_promotions_id ON public.promotions USING btree (id);


--
-- Name: ix_promotions_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_promotions_name ON public.promotions USING btree (name);


--
-- Name: ix_recipe_analytics_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_analytics_created_at ON public.recipe_analytics USING btree (created_at);


--
-- Name: ix_recipe_analytics_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_analytics_id ON public.recipe_analytics USING btree (id);


--
-- Name: ix_recipe_ingredients_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_ingredients_created_at ON public.recipe_ingredients USING btree (created_at);


--
-- Name: ix_recipe_ingredients_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_ingredients_id ON public.recipe_ingredients USING btree (id);


--
-- Name: ix_recipe_nutrition_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_nutrition_created_at ON public.recipe_nutrition USING btree (created_at);


--
-- Name: ix_recipe_nutrition_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_nutrition_id ON public.recipe_nutrition USING btree (id);


--
-- Name: ix_recipe_reviews_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_reviews_created_at ON public.recipe_reviews USING btree (created_at);


--
-- Name: ix_recipe_reviews_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_reviews_id ON public.recipe_reviews USING btree (id);


--
-- Name: ix_recipe_steps_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_steps_created_at ON public.recipe_steps USING btree (created_at);


--
-- Name: ix_recipe_steps_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_steps_id ON public.recipe_steps USING btree (id);


--
-- Name: ix_recipe_versions_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_versions_created_at ON public.recipe_versions USING btree (created_at);


--
-- Name: ix_recipe_versions_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipe_versions_id ON public.recipe_versions USING btree (id);


--
-- Name: ix_recipes_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipes_created_at ON public.recipes USING btree (created_at);


--
-- Name: ix_recipes_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipes_id ON public.recipes USING btree (id);


--
-- Name: ix_recipes_slug; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_recipes_slug ON public.recipes USING btree (slug);


--
-- Name: ix_recipes_title; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_recipes_title ON public.recipes USING btree (title);


--
-- Name: ix_shipments_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipments_created_at ON public.shipments USING btree (created_at);


--
-- Name: ix_shipments_driver_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipments_driver_id ON public.shipments USING btree (driver_id);


--
-- Name: ix_shipments_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipments_id ON public.shipments USING btree (id);


--
-- Name: ix_shipments_order_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipments_order_id ON public.shipments USING btree (order_id);


--
-- Name: ix_shipments_status; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipments_status ON public.shipments USING btree (status);


--
-- Name: ix_shipments_tracking_number; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipments_tracking_number ON public.shipments USING btree (tracking_number);


--
-- Name: ix_shipping_methods_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipping_methods_created_at ON public.shipping_methods USING btree (created_at);


--
-- Name: ix_shipping_methods_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipping_methods_id ON public.shipping_methods USING btree (id);


--
-- Name: ix_shipping_methods_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_shipping_methods_name ON public.shipping_methods USING btree (name);


--
-- Name: ix_tax_templates_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_tax_templates_created_at ON public.tax_templates USING btree (created_at);


--
-- Name: ix_tax_templates_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_tax_templates_id ON public.tax_templates USING btree (id);


--
-- Name: ix_tax_templates_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_tax_templates_name ON public.tax_templates USING btree (name);


--
-- Name: ix_team_members_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_team_members_created_at ON public.team_members USING btree (created_at);


--
-- Name: ix_team_members_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_team_members_id ON public.team_members USING btree (id);


--
-- Name: ix_test_results_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_test_results_id ON public.test_results USING btree (id);


--
-- Name: ix_test_runs_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_test_runs_id ON public.test_runs USING btree (id);


--
-- Name: ix_timeline_events_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_timeline_events_created_at ON public.timeline_events USING btree (created_at);


--
-- Name: ix_timeline_events_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_timeline_events_id ON public.timeline_events USING btree (id);


--
-- Name: ix_users_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_users_created_at ON public.users USING btree (created_at);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_full_name; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_users_full_name ON public.users USING btree (full_name);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_wallet_transactions_customer_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_wallet_transactions_customer_id ON public.wallet_transactions USING btree (customer_id);


--
-- Name: ix_wallet_transactions_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_wallet_transactions_id ON public.wallet_transactions USING btree (id);


--
-- Name: ix_web_page_versions_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_web_page_versions_created_at ON public.web_page_versions USING btree (created_at);


--
-- Name: ix_web_page_versions_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_web_page_versions_id ON public.web_page_versions USING btree (id);


--
-- Name: ix_web_pages_created_at; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_web_pages_created_at ON public.web_pages USING btree (created_at);


--
-- Name: ix_web_pages_id; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_web_pages_id ON public.web_pages USING btree (id);


--
-- Name: ix_web_pages_slug; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE UNIQUE INDEX ix_web_pages_slug ON public.web_pages USING btree (slug);


--
-- Name: ix_web_pages_title; Type: INDEX; Schema: public; Owner: neondb_owner
--

CREATE INDEX ix_web_pages_title ON public.web_pages USING btree (title);


--
-- Name: attribute_values attribute_values_attribute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.attribute_values
    ADD CONSTRAINT attribute_values_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES public.attributes(id);


--
-- Name: blog_posts blog_posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_posts
    ADD CONSTRAINT blog_posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id);


--
-- Name: combined_invoices combined_invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.combined_invoices
    ADD CONSTRAINT combined_invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: credit_notes credit_notes_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.credit_notes
    ADD CONSTRAINT credit_notes_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: credit_notes credit_notes_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.credit_notes
    ADD CONSTRAINT credit_notes_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


--
-- Name: customers customers_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.customer_groups(id);


--
-- Name: about_store fk_about_upd; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.about_store
    ADD CONSTRAINT fk_about_upd FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: about_store_versions fk_about_ver_about; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.about_store_versions
    ADD CONSTRAINT fk_about_ver_about FOREIGN KEY (about_store_id) REFERENCES public.about_store(id);


--
-- Name: about_store_versions fk_about_ver_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.about_store_versions
    ADD CONSTRAINT fk_about_ver_user FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: cms_audit_logs fk_audit_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.cms_audit_logs
    ADD CONSTRAINT fk_audit_user FOREIGN KEY (admin_id) REFERENCES public.users(id);


--
-- Name: awards fk_award_about; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.awards
    ADD CONSTRAINT fk_award_about FOREIGN KEY (about_us_id) REFERENCES public.about_store(id);


--
-- Name: blog_analytics fk_blog_ana; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_analytics
    ADD CONSTRAINT fk_blog_ana FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- Name: blog_comments fk_blog_com; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT fk_blog_com FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- Name: blog_comments fk_blog_com_appr; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_comments
    ADD CONSTRAINT fk_blog_com_appr FOREIGN KEY (approved_by) REFERENCES public.users(id);


--
-- Name: blog_post_versions fk_blog_ver; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_post_versions
    ADD CONSTRAINT fk_blog_ver FOREIGN KEY (post_id) REFERENCES public.blog_posts(id);


--
-- Name: blog_post_versions fk_blog_ver_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.blog_post_versions
    ADD CONSTRAINT fk_blog_ver_user FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: certifications fk_cert_about; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.certifications
    ADD CONSTRAINT fk_cert_about FOREIGN KEY (about_us_id) REFERENCES public.about_store(id);


--
-- Name: faq_analytics fk_faq_ana_faq; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_analytics
    ADD CONSTRAINT fk_faq_ana_faq FOREIGN KEY (faq_id) REFERENCES public.faqs(id);


--
-- Name: faq_versions fk_faq_ver_faq; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_versions
    ADD CONSTRAINT fk_faq_ver_faq FOREIGN KEY (faq_id) REFERENCES public.faqs(id);


--
-- Name: faq_versions fk_faq_ver_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_versions
    ADD CONSTRAINT fk_faq_ver_user FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: faq_votes fk_faq_vote_faq; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.faq_votes
    ADD CONSTRAINT fk_faq_vote_faq FOREIGN KEY (faq_id) REFERENCES public.faqs(id);


--
-- Name: invoices fk_invoices_combined_invoice_id; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT fk_invoices_combined_invoice_id FOREIGN KEY (combined_invoice_id) REFERENCES public.combined_invoices(id);


--
-- Name: legal_documents fk_legal_pub; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.legal_documents
    ADD CONSTRAINT fk_legal_pub FOREIGN KEY (published_by) REFERENCES public.users(id);


--
-- Name: legal_document_versions fk_legal_ver; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.legal_document_versions
    ADD CONSTRAINT fk_legal_ver FOREIGN KEY (document_id) REFERENCES public.legal_documents(id);


--
-- Name: legal_document_versions fk_legal_ver_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.legal_document_versions
    ADD CONSTRAINT fk_legal_ver_user FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: page_analytics fk_page_ana; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.page_analytics
    ADD CONSTRAINT fk_page_ana FOREIGN KEY (page_id) REFERENCES public.web_pages(id);


--
-- Name: web_pages fk_page_pub_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.web_pages
    ADD CONSTRAINT fk_page_pub_user FOREIGN KEY (published_by) REFERENCES public.users(id);


--
-- Name: web_pages fk_page_upd_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.web_pages
    ADD CONSTRAINT fk_page_upd_user FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: web_page_versions fk_page_ver; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.web_page_versions
    ADD CONSTRAINT fk_page_ver FOREIGN KEY (page_id) REFERENCES public.web_pages(id);


--
-- Name: web_page_versions fk_page_ver_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.web_page_versions
    ADD CONSTRAINT fk_page_ver_user FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: recipe_analytics fk_rana_rec; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_analytics
    ADD CONSTRAINT fk_rana_rec FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: recipe_versions fk_rec_ver; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_versions
    ADD CONSTRAINT fk_rec_ver FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: recipe_versions fk_rec_ver_user; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_versions
    ADD CONSTRAINT fk_rec_ver_user FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: recipe_ingredients fk_ring_rec; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_ingredients
    ADD CONSTRAINT fk_ring_rec FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: recipe_nutrition fk_rnut_rec; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_nutrition
    ADD CONSTRAINT fk_rnut_rec FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: recipes_products fk_rp_prod; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipes_products
    ADD CONSTRAINT fk_rp_prod FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: recipes_products fk_rp_req; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipes_products
    ADD CONSTRAINT fk_rp_req FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: recipe_reviews fk_rrev_rec; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_reviews
    ADD CONSTRAINT fk_rrev_rec FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: recipe_steps fk_rstep_rec; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.recipe_steps
    ADD CONSTRAINT fk_rstep_rec FOREIGN KEY (recipe_id) REFERENCES public.recipes(id);


--
-- Name: timeline_events fk_time_about; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.timeline_events
    ADD CONSTRAINT fk_time_about FOREIGN KEY (about_us_id) REFERENCES public.about_store(id);


--
-- Name: gift_cards gift_cards_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.gift_cards
    ADD CONSTRAINT gift_cards_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: invoices invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: invoices invoices_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: invoices invoices_salesperson_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_salesperson_id_fkey FOREIGN KEY (salesperson_id) REFERENCES public.users(id);


--
-- Name: locations locations_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: memberships memberships_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: memberships memberships_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.memberships
    ADD CONSTRAINT memberships_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.membership_plans(id);


--
-- Name: menus menus_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.menus(id);


--
-- Name: notifications notifications_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: order_items order_items_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- Name: order_items orderitems_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT orderitems_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: order_items orderitems_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT orderitems_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: orders orders_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);


--
-- Name: orders orders_promotion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.promotions(id);


--
-- Name: order_status_updates orderstatusupdates_changed_by_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_status_updates
    ADD CONSTRAINT orderstatusupdates_changed_by_id_fkey FOREIGN KEY (changed_by_id) REFERENCES public.users(id);


--
-- Name: order_status_updates orderstatusupdates_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.order_status_updates
    ADD CONSTRAINT orderstatusupdates_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: partner_prices partner_prices_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.partner_prices
    ADD CONSTRAINT partner_prices_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.customers(id);


--
-- Name: partner_prices partner_prices_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.partner_prices
    ADD CONSTRAINT partner_prices_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: payments payments_combined_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_combined_invoice_id_fkey FOREIGN KEY (combined_invoice_id) REFERENCES public.combined_invoices(id);


--
-- Name: payments payments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: payments payments_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


--
-- Name: product_variants product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: shipments shipments_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.users(id);


--
-- Name: shipments shipments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: test_results test_results_test_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.test_results
    ADD CONSTRAINT test_results_test_run_id_fkey FOREIGN KEY (test_run_id) REFERENCES public.test_runs(id);


--
-- Name: variant_attribute_values variant_attribute_values_attribute_value_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.variant_attribute_values
    ADD CONSTRAINT variant_attribute_values_attribute_value_id_fkey FOREIGN KEY (attribute_value_id) REFERENCES public.attribute_values(id);


--
-- Name: variant_attribute_values variant_attribute_values_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.variant_attribute_values
    ADD CONSTRAINT variant_attribute_values_variant_id_fkey FOREIGN KEY (variant_id) REFERENCES public.product_variants(id);


--
-- Name: wallet_transactions wallet_transactions_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: neondb_owner
--

ALTER TABLE ONLY public.wallet_transactions
    ADD CONSTRAINT wallet_transactions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: neondb_owner
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict eCRIsbzid1Tvn2FaJSmpkfvU1U1QcRSjUeOoEFDYF0oR8ILq6rZyJFbFVLB7VSc

